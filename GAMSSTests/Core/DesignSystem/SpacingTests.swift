import XCTest
@testable import GAMSS

final class SpacingTests: XCTestCase {
    func test_scale_matchesFigmaTokens() {
        XCTAssertEqual(Spacing.spacing000, 0)
        XCTAssertEqual(Spacing.spacing025, 2)
        XCTAssertEqual(Spacing.spacing050, 4)
        XCTAssertEqual(Spacing.spacing075, 6)
        XCTAssertEqual(Spacing.spacing100, 8)
        XCTAssertEqual(Spacing.spacing150, 10)
        XCTAssertEqual(Spacing.spacing200, 12)
        XCTAssertEqual(Spacing.spacing300, 16)
        XCTAssertEqual(Spacing.spacing400, 20)
        XCTAssertEqual(Spacing.spacing500, 24)
        XCTAssertEqual(Spacing.spacing550, 28)
        XCTAssertEqual(Spacing.spacing600, 32)
        XCTAssertEqual(Spacing.spacing700, 40)
        XCTAssertEqual(Spacing.spacing800, 48)
        XCTAssertEqual(Spacing.spacing900, 64)
    }
}
