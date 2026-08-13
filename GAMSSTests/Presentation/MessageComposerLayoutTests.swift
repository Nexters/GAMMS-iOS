//
//  MessageComposerLayoutTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import XCTest
@testable import GAMSS

final class MessageComposerLayoutTests: XCTestCase {
    func test_collapsedHeight_isOneLineHeightPlusVerticalPadding() {
        let expected = Typography.body3Regular.metrics.lineHeight + Spacing.spacing300 * 2
        XCTAssertEqual(MessageComposerLayout.collapsedHeight, expected)
    }

    func test_clampedHeight_belowCollapsedHeight_clampsUpToCollapsedHeight() {
        let result = MessageComposerLayout.clampedHeight(forMeasuredContentHeight: 10)

        XCTAssertEqual(result, MessageComposerLayout.collapsedHeight)
    }

    func test_clampedHeight_withinRange_returnsMeasuredHeightUnchanged() {
        let measured = MessageComposerLayout.collapsedHeight + 40

        let result = MessageComposerLayout.clampedHeight(forMeasuredContentHeight: measured)

        XCTAssertEqual(result, measured)
    }

    func test_clampedHeight_aboveMaxExpandedHeight_clampsDownToMaxExpandedHeight() {
        let result = MessageComposerLayout.clampedHeight(forMeasuredContentHeight: 500)

        XCTAssertEqual(result, MessageComposerLayout.maxExpandedHeight)
    }

    func test_maxExpandedHeight_is220() {
        XCTAssertEqual(MessageComposerLayout.maxExpandedHeight, 220)
    }
}
