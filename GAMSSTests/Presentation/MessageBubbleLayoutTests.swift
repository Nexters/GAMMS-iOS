//
//  MessageBubbleLayoutTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/12/26.
//

import XCTest
@testable import GAMSS

final class MessageBubbleLayoutTests: XCTestCase {
    func test_maxBubbleWidth_subtractsOppositeMarginAndContainerPadding() {
        let result = MessageBubbleLayout.maxBubbleWidth(availableWidth: 390, containerPadding: 32)

        XCTAssertEqual(result, 390 - 84 - 32)
    }

    func test_maxBubbleWidth_zeroContainerPadding_onlySubtractsOppositeMargin() {
        let result = MessageBubbleLayout.maxBubbleWidth(availableWidth: 200, containerPadding: 0)

        XCTAssertEqual(result, 200 - 84)
    }

    func test_maxBubbleWidth_zeroAvailableWidth_clampsToZeroInsteadOfNegative() {
        let result = MessageBubbleLayout.maxBubbleWidth(availableWidth: 0, containerPadding: 0)

        XCTAssertEqual(result, 0)
    }

    func test_receivedBubbleMaxWidth_subtractsIndent() {
        let result = MessageBubbleLayout.receivedBubbleMaxWidth(maxWidth: 260)

        XCTAssertEqual(result, 260 - 32)
    }

    func test_receivedBubbleMaxWidth_clampsToZeroInsteadOfNegative() {
        let result = MessageBubbleLayout.receivedBubbleMaxWidth(maxWidth: 10)

        XCTAssertEqual(result, 0)
    }
}
