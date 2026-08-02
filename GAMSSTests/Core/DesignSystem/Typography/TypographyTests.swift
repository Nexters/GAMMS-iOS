import XCTest
@testable import GAMSS

final class TypographyTests: XCTestCase {
    private struct Expected {
        let fontSize: CGFloat
        let letterSpacing: CGFloat
        let lineHeight: CGFloat
        let weight: FontWeight
    }

    private let expected: [Typography: Expected] = [
        .display1: Expected(fontSize: 48, letterSpacing: -0.4, lineHeight: 56, weight: .bold),
        .display2: Expected(fontSize: 36, letterSpacing: -0.2, lineHeight: 40, weight: .bold),
        .title1: Expected(fontSize: 28, letterSpacing: -0.2, lineHeight: 32, weight: .bold),
        .title2: Expected(fontSize: 24, letterSpacing: -0.15, lineHeight: 28, weight: .bold),
        .title3: Expected(fontSize: 20, letterSpacing: -0.1, lineHeight: 24, weight: .bold),
        .title4: Expected(fontSize: 18, letterSpacing: -0.1, lineHeight: 24, weight: .bold),
        .title5: Expected(fontSize: 16, letterSpacing: -0.1, lineHeight: 20, weight: .bold),
        .subtitle1: Expected(fontSize: 20, letterSpacing: -0.1, lineHeight: 28, weight: .semiBold),
        .subtitle2: Expected(fontSize: 18, letterSpacing: -0.1, lineHeight: 24, weight: .semiBold),
        .subtitle3: Expected(fontSize: 16, letterSpacing: -0.1, lineHeight: 24, weight: .semiBold),
        .subtitle4: Expected(fontSize: 14, letterSpacing: -0.1, lineHeight: 20, weight: .semiBold),
        .body1Medium: Expected(fontSize: 20, letterSpacing: -0.1, lineHeight: 32, weight: .medium),
        .body2Medium: Expected(fontSize: 18, letterSpacing: -0.1, lineHeight: 28, weight: .medium),
        .body3Medium: Expected(fontSize: 16, letterSpacing: -0.1, lineHeight: 24, weight: .medium),
        .body4Medium: Expected(fontSize: 14, letterSpacing: -0.1, lineHeight: 20, weight: .medium),
        .body5Medium: Expected(fontSize: 12, letterSpacing: -0.1, lineHeight: 18, weight: .medium),
        .body6Medium: Expected(fontSize: 10, letterSpacing: -0.1, lineHeight: 14, weight: .medium),
        .body1Regular: Expected(fontSize: 20, letterSpacing: -0.1, lineHeight: 32, weight: .regular),
        .body2Regular: Expected(fontSize: 18, letterSpacing: -0.1, lineHeight: 28, weight: .regular),
        .body3Regular: Expected(fontSize: 16, letterSpacing: -0.1, lineHeight: 24, weight: .regular),
        .body4Regular: Expected(fontSize: 14, letterSpacing: -0.1, lineHeight: 20, weight: .regular),
        .body5Regular: Expected(fontSize: 12, letterSpacing: -0.1, lineHeight: 18, weight: .regular),
        .body6Regular: Expected(fontSize: 10, letterSpacing: -0.1, lineHeight: 14, weight: .regular),
        .paragraph1: Expected(fontSize: 16, letterSpacing: -0.1, lineHeight: 32, weight: .regular),
        .paragraph2: Expected(fontSize: 14, letterSpacing: -0.1, lineHeight: 28, weight: .regular),
        .paragraph3: Expected(fontSize: 12, letterSpacing: -0.1, lineHeight: 24, weight: .regular),
        .caption1: Expected(fontSize: 14, letterSpacing: -0.1, lineHeight: 20, weight: .medium),
        .caption2: Expected(fontSize: 12, letterSpacing: -0.1, lineHeight: 18, weight: .medium),
        .caption3: Expected(fontSize: 10, letterSpacing: -0.1, lineHeight: 14, weight: .medium),
        .caption4: Expected(fontSize: 10, letterSpacing: -0.1, lineHeight: 14, weight: .regular),
    ]

    func test_allCases_haveExpectedMetrics() {
        XCTAssertEqual(Typography.allCases.count, 30)
        for scale in Typography.allCases {
            let metrics = scale.metrics
            guard let expectation = expected[scale] else {
                XCTFail("no expectation defined for \(scale)")
                continue
            }
            XCTAssertEqual(metrics.fontSize, expectation.fontSize, "\(scale) fontSize")
            XCTAssertEqual(metrics.letterSpacing, expectation.letterSpacing, "\(scale) letterSpacing")
            XCTAssertEqual(metrics.lineHeight, expectation.lineHeight, "\(scale) lineHeight")
            XCTAssertEqual(metrics.weight, expectation.weight, "\(scale) weight")
        }
    }
}
