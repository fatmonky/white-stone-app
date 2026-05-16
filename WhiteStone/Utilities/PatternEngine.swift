import Foundation

struct PatternObservation: Equatable, Identifiable {
    let id: String
    let text: String
}

enum PatternEngine {
    static func observations(
        from stones: [Stone],
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [PatternObservation] {
        var observations: [PatternObservation] = []

        if let observation = timeOfDayClustering(from: stones, now: now, calendar: calendar) {
            observations.append(observation)
        }
        if let observation = mostTaggedRoot(from: stones, now: now, calendar: calendar) {
            observations.append(observation)
        }
        if let observation = intensityTilt(from: stones, now: now, calendar: calendar) {
            observations.append(observation)
        }
        if let observation = intensityColorCrossTag(from: stones, now: now, calendar: calendar) {
            observations.append(observation)
        }
        if let observation = loggingCadence(from: stones, now: now, calendar: calendar) {
            observations.append(observation)
        }

        return Array(observations.prefix(4))
    }

    private static func timeOfDayClustering(
        from stones: [Stone],
        now: Date,
        calendar: Calendar
    ) -> PatternObservation? {
        let recentStones = stonesWithinLastDays(14, from: stones, now: now, calendar: calendar)
        for type in [StoneType.black, StoneType.white] {
            let matchingStones = recentStones.filter { $0.type == type }
            guard matchingStones.count >= 10 else { continue }

            let buckets = Dictionary(grouping: matchingStones) { stone in
                TimeBucket(date: stone.timestamp, calendar: calendar)
            }
            guard let dominant = buckets.max(by: { $0.value.count < $1.value.count }),
                  dominant.value.count * 2 > matchingStones.count else {
                continue
            }

            return PatternObservation(
                id: "time-of-day-\(type.rawValue)",
                text: "in the last two weeks, your \(type.rawValue) stones often appeared between \(dominant.key.label)."
            )
        }
        return nil
    }

    private static func mostTaggedRoot(
        from stones: [Stone],
        now: Date,
        calendar: Calendar
    ) -> PatternObservation? {
        let recentStones = stonesWithinLastDays(14, from: stones, now: now, calendar: calendar)
        let roots = recentStones.flatMap(\.rootDisplayNames)
        guard roots.count >= 5 else { return nil }

        let counts = Dictionary(grouping: roots, by: { $0 }).mapValues(\.count)
        guard let root = counts.sorted(by: mostFrequentThenAlphabetical).first?.key else { return nil }
        return PatternObservation(
            id: "most-tagged-root",
            text: "most-tagged root in the last two weeks: \(root)."
        )
    }

    private static func intensityTilt(
        from stones: [Stone],
        now: Date,
        calendar: Calendar
    ) -> PatternObservation? {
        let intensities = stonesWithinLastDays(14, from: stones, now: now, calendar: calendar)
            .compactMap(\.intensity)
        guard intensities.count >= 5 else { return nil }

        let strong = intensities.filter { $0 == .strong }.count
        let weak = intensities.filter { $0 == .weak }.count
        if strong >= weak * 2, strong > 0 {
            return PatternObservation(
                id: "intensity-tilt-strong",
                text: "in the last two weeks, your stones have leaned strong."
            )
        }
        if weak >= strong * 2, weak > 0 {
            return PatternObservation(
                id: "intensity-tilt-weak",
                text: "in the last two weeks, your stones have leaned weak."
            )
        }
        return nil
    }

    private static func intensityColorCrossTag(
        from stones: [Stone],
        now: Date,
        calendar: Calendar
    ) -> PatternObservation? {
        let taggedStones = stonesWithinLastDays(14, from: stones, now: now, calendar: calendar)
            .filter { $0.intensity != nil }
        for intensity in [StoneIntensity.strong, StoneIntensity.weak] {
            let matching = taggedStones.filter { $0.intensity == intensity }
            guard matching.count >= 5 else { continue }

            let white = matching.filter { $0.type == .white }.count
            let black = matching.count - white
            if black * 10 >= matching.count * 7 {
                return PatternObservation(
                    id: "intensity-color-\(intensity.rawValue)-black",
                    text: "your \(intensity.displayName) stones recently have mostly been black."
                )
            }
            if white * 10 >= matching.count * 7 {
                return PatternObservation(
                    id: "intensity-color-\(intensity.rawValue)-white",
                    text: "your \(intensity.displayName) stones recently have mostly been white."
                )
            }
        }
        return nil
    }

    private static func loggingCadence(
        from stones: [Stone],
        now: Date,
        calendar: Calendar
    ) -> PatternObservation? {
        guard !stones.isEmpty else { return nil }
        let recentDayKeys = Set(stonesWithinLastDays(14, from: stones, now: now, calendar: calendar).map {
            dayKey(for: $0.timestamp, calendar: calendar)
        })
        if recentDayKeys.count >= 10 {
            return PatternObservation(
                id: "cadence-most-days",
                text: "you've been logging on most days in the last two weeks."
            )
        }

        guard let latest = stones.map(\.timestamp).max() else { return nil }
        let today = calendar.startOfDay(for: now)
        let latestDay = calendar.startOfDay(for: latest)
        let daysSinceLatest = calendar.dateComponents([.day], from: latestDay, to: today).day ?? 0
        if daysSinceLatest >= 3 {
            return PatternObservation(
                id: "cadence-few-days",
                text: "it's been a few days since your last entry."
            )
        }
        return nil
    }

    private static func stonesWithinLastDays(
        _ days: Int,
        from stones: [Stone],
        now: Date,
        calendar: Calendar
    ) -> [Stone] {
        let todayStart = calendar.startOfDay(for: now)
        guard let start = calendar.date(byAdding: .day, value: -(days - 1), to: todayStart),
              let end = calendar.date(byAdding: .day, value: 1, to: todayStart) else {
            return []
        }
        return stones.filter { $0.timestamp >= start && $0.timestamp < end }
    }

    private static func dayKey(for date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return [
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0,
        ]
        .map(String.init)
        .joined(separator: "-")
    }

    private static func mostFrequentThenAlphabetical(
        lhs: (key: String, value: Int),
        rhs: (key: String, value: Int)
    ) -> Bool {
        if lhs.value == rhs.value {
            return lhs.key < rhs.key
        }
        return lhs.value > rhs.value
    }
}

private enum TimeBucket: Hashable {
    case morning
    case midday
    case afternoon
    case evening
    case night

    init(date: Date, calendar: Calendar) {
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 6..<10:
            self = .morning
        case 10..<14:
            self = .midday
        case 14..<18:
            self = .afternoon
        case 18..<22:
            self = .evening
        default:
            self = .night
        }
    }

    var label: String {
        switch self {
        case .morning:
            return "6:00 and 10:00"
        case .midday:
            return "10:00 and 14:00"
        case .afternoon:
            return "14:00 and 18:00"
        case .evening:
            return "18:00 and 22:00"
        case .night:
            return "22:00 and 6:00"
        }
    }
}
