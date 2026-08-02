import XCTest
@testable import GAMSS

final class RadiusTests: XCTestCase {
    func test_scale_matchesFigmaTokens() {
        XCTAssertEqual(Radius.radius000, 0)
        XCTAssertEqual(Radius.radius025, 2)
        XCTAssertEqual(Radius.radius050, 4)
        XCTAssertEqual(Radius.radius075, 6)
        XCTAssertEqual(Radius.radius100, 8)
        XCTAssertEqual(Radius.radius150, 10)
        XCTAssertEqual(Radius.radius200, 12)
        XCTAssertEqual(Radius.radius300, 16)
        XCTAssertEqual(Radius.radius400, 20)
        XCTAssertEqual(Radius.radius500, 24)
        XCTAssertEqual(Radius.radiusFull, 999)
    }
}
