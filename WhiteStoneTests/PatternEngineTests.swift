import XCTest
@testable import WhiteStone

final class PatternEngineTests: XCTestCase {
    private var calendar: Calendar!
    private var now: Date!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        now = date(day: 20, hour: 12)
    }

    func testShowsEmptyPatternsWhenThereIsNotEnoughData() {
        let observations = PatternEngine.observations(
            from: [
                stone(.white, day: 20, hour: 9),
                stone(.black, day: 19, hour: 15),
            ],
            now: now,
            calendar: calendar
        )

        XCTAssertTrue(observations.isEmpty)
    }

    func testTimeOfDayClusteringRequiresDominantBucket() {
        let stones = (0..<6).map { stone(.black, day: 20, hour: 15, minute: $0) }
            + (0..<4).map { stone(.black, day: 19, hour: 9, minute: $0) }

        let observations = PatternEngine.observations(from: stones, now: now, calendar: calendar)

        XCTAssertEqual(
            observations.first?.text,
            "in the last two weeks, your black stones often appeared between 14:00 and 18:00."
        )
    }

    func testMostTaggedRootUsesRecentRootTags() {
        let stones = [
            stone(.black, day: 20, hour: 8, roots: [.illWill]),
            stone(.black, day: 20, hour: 9, roots: [.illWill]),
            stone(.black, day: 19, hour: 8, roots: [.illWill]),
            stone(.black, day: 19, hour: 9, roots: [.harming]),
            stone(.white, day: 18, hour: 8, roots: [.kindness]),
        ]

        let observations = PatternEngine.observations(from: stones, now: now, calendar: calendar)

        XCTAssertTrue(observations.contains {
            $0.text == "most-tagged root in the last two weeks: ill will."
        })
    }

    func testIntensityTiltRendersOnlyTwoToOneTilts() {
        let stones = [
            stone(.white, day: 20, hour: 8, intensity: .strong),
            stone(.white, day: 20, hour: 9, intensity: .strong),
            stone(.black, day: 19, hour: 8, intensity: .strong),
            stone(.black, day: 19, hour: 9, intensity: .strong),
            stone(.white, day: 18, hour: 8, intensity: .weak),
        ]

        let observations = PatternEngine.observations(from: stones, now: now, calendar: calendar)

        XCTAssertTrue(observations.contains {
            $0.text == "in the last two weeks, your stones have leaned strong."
        })
    }

    func testIntensityColorCrossTagRendersDominantColorForIntensity() {
        let stones = [
            stone(.black, day: 20, hour: 8, intensity: .strong),
            stone(.black, day: 20, hour: 9, intensity: .strong),
            stone(.black, day: 19, hour: 8, intensity: .strong),
            stone(.black, day: 19, hour: 9, intensity: .strong),
            stone(.white, day: 18, hour: 8, intensity: .strong),
        ]

        let observations = PatternEngine.observations(from: stones, now: now, calendar: calendar)

        XCTAssertTrue(observations.contains {
            $0.text == "your strong stones recently have mostly been black."
        })
    }

    func testLoggingCadenceObservesMostDaysInLastTwoWeeks() {
        let stones = (11...20).map { day in
            stone(.white, day: day, hour: 8)
        }

        let observations = PatternEngine.observations(from: stones, now: now, calendar: calendar)

        XCTAssertTrue(observations.contains {
            $0.text == "you've been logging on most days in the last two weeks."
        })
    }

    func testLoggingCadenceObservesFewDaysSinceLastEntry() {
        let stones = [
            stone(.white, day: 15, hour: 8),
            stone(.black, day: 14, hour: 8),
        ]

        let observations = PatternEngine.observations(from: stones, now: now, calendar: calendar)

        XCTAssertEqual(observations.map(\.text), ["it's been a few days since your last entry."])
    }

    func testLimitsRenderedObservationsToFour() {
        let stones = (0..<12).map { stone(.black, day: 20, hour: 15, minute: $0, roots: [.illWill], intensity: .strong) }
            + (0..<3).map { stone(.white, day: 19, hour: 8, minute: $0, roots: [.kindness], intensity: .strong) }
            + [
                stone(.white, day: 18, hour: 8),
                stone(.white, day: 17, hour: 8),
                stone(.white, day: 16, hour: 8),
            ]

        let observations = PatternEngine.observations(from: stones, now: now, calendar: calendar)

        XCTAssertEqual(observations.count, 4)
    }

    private func stone(
        _ type: StoneType,
        day: Int,
        hour: Int,
        minute: Int = 0,
        roots: [StoneRoot] = [],
        intensity: StoneIntensity? = nil
    ) -> Stone {
        Stone(
            type: type,
            timestamp: date(day: day, hour: hour, minute: minute),
            roots: roots,
            intensity: intensity
        )
    }

    private func date(day: Int, hour: Int, minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(
            timeZone: calendar.timeZone,
            year: 2026,
            month: 5,
            day: day,
            hour: hour,
            minute: minute
        ))!
    }
}
