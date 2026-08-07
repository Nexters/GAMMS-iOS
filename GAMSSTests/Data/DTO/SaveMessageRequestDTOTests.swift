//
//  SaveMessageRequestDTOTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import XCTest
@testable import GAMSS

final class SaveMessageRequestDTOTests: XCTestCase {
    // Swift JSONEncoder는 기본적으로 옵셔널이 nil이어도 "key": null로 인코딩한다 — 커스텀
    // encode(to:)가 없으면 이 테스트는 실패한다. 서버는 키 부재로 "새 대화"/"컨텍스트 없음"을
    // 판단하므로(Kotlin encodeDefaults=false와 동일하게 맞춰야 함), null이 아니라 키 자체가
    // 빠져야 한다.
    func test_encode_withAllOptionalFieldsNil_omitsThoseKeysEntirely() throws {
        let dto = SaveMessageRequestDTO(content: "안녕", conversationId: nil, repliesToMessageId: nil, currentConversationSummary: nil)

        let data = try JSONEncoder().encode(dto)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertFalse(json.contains("conversationId"), "conversationId 키가 nil일 때 빠져야 함")
        XCTAssertFalse(json.contains("repliesToMessageId"), "repliesToMessageId 키가 nil일 때 빠져야 함")
        XCTAssertFalse(json.contains("currentConversationSummary"), "currentConversationSummary 키가 nil일 때 빠져야 함")
        XCTAssertTrue(json.contains("\"content\":\"안녕\""))
    }

    func test_encode_withAllOptionalFieldsPresent_includesAllKeys() throws {
        let dto = SaveMessageRequestDTO(content: "안녕", conversationId: 1, repliesToMessageId: 2, currentConversationSummary: "요약본")

        let data = try JSONEncoder().encode(dto)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertTrue(json.contains("\"conversationId\":1"))
        XCTAssertTrue(json.contains("\"repliesToMessageId\":2"))
        XCTAssertTrue(json.contains("\"currentConversationSummary\":\"요약본\""))
    }
}
