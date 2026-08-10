//
//  CreateMessageRequestDTOTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/10/26.
//

import XCTest
@testable import GAMSS

final class CreateMessageRequestDTOTests: XCTestCase {
    // Swift의 합성 Encodable 구현은 옵셔널 프로퍼티가 nil이면 encodeIfPresent를 통해 키
    // 자체를 생략한다(별도 커스텀 encode(to:) 없이도 보장됨). 서버는 키 부재로 "새 대화"/
    // "컨텍스트 없음"을 판단하므로 이 동작이 깨지면 안 된다.
    func test_encode_withAllOptionalFieldsNil_omitsThoseKeysEntirely() throws {
        let dto = CreateMessageRequestDTO(
            conversationId: nil,
            content: "안녕",
            repliesToMessageId: nil,
            currentConversationSummary: nil,
            excludeCharacters: []
        )

        let data = try JSONEncoder().encode(dto)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertFalse(json.contains("conversationId"), "conversationId 키가 nil일 때 빠져야 함")
        XCTAssertFalse(json.contains("repliesToMessageId"), "repliesToMessageId 키가 nil일 때 빠져야 함")
        XCTAssertFalse(json.contains("currentConversationSummary"), "currentConversationSummary 키가 nil일 때 빠져야 함")
        XCTAssertTrue(json.contains("\"content\":\"안녕\""))
    }

    func test_encode_withAllOptionalFieldsPresent_includesAllKeys() throws {
        let dto = CreateMessageRequestDTO(
            conversationId: 1,
            content: "안녕",
            repliesToMessageId: 2,
            currentConversationSummary: "요약본",
            excludeCharacters: []
        )

        let data = try JSONEncoder().encode(dto)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertTrue(json.contains("\"conversationId\":1"))
        XCTAssertTrue(json.contains("\"repliesToMessageId\":2"))
        XCTAssertTrue(json.contains("\"currentConversationSummary\":\"요약본\""))
    }
}
