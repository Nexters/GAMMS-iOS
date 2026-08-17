//
//  CreateCardRequestDTOTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/15/26.
//

import XCTest
@testable import GAMSS

final class CreateCardRequestDTOTests: XCTestCase {
    // CreateMessageRequestDTO와 반대로, 카드 생성 API는 emotion이 없을 때 키 자체가 아니라
    // 명시적 null 값을 기대한다 — 합성 Encodable 기본 동작(nil optional을 null로 인코딩)을
    // 그대로 두고 커스텀 encode(to:)를 만들지 않는 이유.
    func test_encode_withNilEmotion_encodesExplicitNull() throws {
        let dto = CreateCardRequestDTO(conversationId: 1, emotion: nil, summary: "요약")

        let data = try JSONEncoder().encode(dto)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertTrue(json.contains("\"emotion\":null"), "emotion이 nil이면 키는 남고 값만 null이어야 함")
    }

    func test_encode_withEmotion_includesServerKeyString() throws {
        let dto = CreateCardRequestDTO(conversationId: 1, emotion: "ANGER", summary: "요약")

        let data = try JSONEncoder().encode(dto)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertTrue(json.contains("\"emotion\":\"ANGER\""))
    }
}
