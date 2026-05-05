import XCTest
@testable import WhiteStone

final class StoneTagTests: XCTestCase {
    func testAllowedRootsAreConstrainedByStoneType() {
        XCTAssertEqual(StoneRoot.allowed(for: .white), [.renunciation, .kindness, .harmlessness])
        XCTAssertEqual(StoneRoot.allowed(for: .black), [.sensual, .illWill, .harming])
    }

    func testStoneRootsPreserveMultipleSelectedRoots() {
        let stone = Stone(type: .white, roots: [.renunciation, .kindness])

        XCTAssertEqual(stone.roots, [.renunciation, .kindness])
        XCTAssertEqual(stone.root, .renunciation)
    }

    func testTagSummaryCombinesRootsCustomDescriptorsAndIntensity() {
        let stone = Stone(
            type: .black,
            roots: [.illWill],
            rootDescriptor: "envy\nfear",
            intensity: .strong
        )

        XCTAssertEqual(stone.tagSummaryText, "ill will · envy · fear · strong")
    }
}
