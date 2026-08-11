//
//  QuotedReplyHeaderTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/12/26.
//

import XCTest
@testable import GAMSS

final class QuotedReplyHeaderTests: XCTestCase {
    func test_label_characterSender_returnsReplyToCharacterName() {
        XCTAssertEqual(QuotedReplyHeader.label(forQuotedSender: .character(.anxiety)), "불안이에게 답장")
    }

    func test_label_differentCharacterSender_usesThatCharactersName() {
        XCTAssertEqual(QuotedReplyHeader.label(forQuotedSender: .character(.prickly)), "까칠이에게 답장")
    }

    func test_label_userSender_returnsNil() {
        // 캐릭터의 1차 댓글은 대부분 사용자 메시지를 가리키므로(주 경로),
        // 이 경우 인용 헤더 없이 일반 버블로 렌더링되어야 한다.
        XCTAssertNil(QuotedReplyHeader.label(forQuotedSender: .user))
    }
}
