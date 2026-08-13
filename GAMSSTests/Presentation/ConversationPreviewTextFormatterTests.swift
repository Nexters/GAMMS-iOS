//
//  ConversationPreviewTextFormatterTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import XCTest
@testable import GAMSS

final class ConversationPreviewTextFormatterTests: XCTestCase {
    func test_truncated_exactlyMaxLength_returnsUnchanged() {
        let text = String(repeating: "가", count: 25)

        XCTAssertEqual(ConversationPreviewTextFormatter.truncated(text), text)
    }

    func test_truncated_overMaxLength_truncatesAndAppendsEllipsis() {
        let text = String(repeating: "가", count: 26)

        let result = ConversationPreviewTextFormatter.truncated(text)

        XCTAssertEqual(result, String(repeating: "가", count: 25) + "…")
    }

    func test_truncated_shortText_returnsUnchanged() {
        XCTAssertEqual(ConversationPreviewTextFormatter.truncated("짧은 텍스트"), "짧은 텍스트")
    }
}
