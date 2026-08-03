import XCTest
import UIKit
@testable import GAMSS

final class FontWeightTests: XCTestCase {
    func test_postScriptName_isRegisteredAndLoadable() {
        let weights: [FontWeight] = [.regular, .medium, .semiBold, .bold]
        let expectedNames = [
            "Pretendard-Regular",
            "Pretendard-Medium",
            "Pretendard-SemiBold",
            "Pretendard-Bold",
        ]
        for (weight, expectedName) in zip(weights, expectedNames) {
            XCTAssertEqual(weight.postScriptName(), expectedName)
            XCTAssertNotNil(UIFont(name: weight.postScriptName(), size: 16), "\(weight.postScriptName()) is not registered — check Info.plist UIAppFonts")
        }
    }
}
