//
//  ChatComposerViewTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/12/26.
//

import XCTest
@testable import GAMSS

final class ChatComposerViewTests: XCTestCase {
    func test_hasText_blankInput_returnsFalse() {
        XCTAssertFalse(ChatComposerView.hasText("   "))
    }

    func test_hasText_emptyInput_returnsFalse() {
        XCTAssertFalse(ChatComposerView.hasText(""))
    }

    func test_hasText_nonBlankInput_returnsTrue() {
        XCTAssertTrue(ChatComposerView.hasText("안녕"))
    }
}
