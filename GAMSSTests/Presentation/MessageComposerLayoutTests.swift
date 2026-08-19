//
//  MessageComposerLayoutTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/19/26.
//

import XCTest
@testable import GAMSS

final class MessageComposerLayoutTests: XCTestCase {
    func test_height_notExpanded_returnsCollapsedHeight() {
        XCTAssertEqual(MessageComposerLayout.height(isExpanded: false), 116)
    }

    func test_height_expanded_returnsExpandedHeight() {
        XCTAssertEqual(MessageComposerLayout.height(isExpanded: true), 150)
    }
}
