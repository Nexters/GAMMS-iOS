//
//  ConversationMessageDTOTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import XCTest
@testable import GAMSS

final class ConversationMessageDTOTests: XCTestCase {
    private func makeDTO(senderType: String, emotionType: String?) -> ConversationMessageDTO {
        ConversationMessageDTO(
            id: 1, conversationId: 10, senderType: senderType, emotionType: emotionType,
            content: "내용", repliesToMessageId: nil, rootMessageId: nil, createdAt: "2026-08-07T00:00:00Z"
        )
    }

    func test_toDomain_parsesCreatedAtAsISO8601Date() throws {
        let dto = makeDTO(senderType: "USER", emotionType: nil)

        let createdAt = try XCTUnwrap(dto.toDomain()?.createdAt)

        let formatter = ISO8601DateFormatter()
        XCTAssertEqual(createdAt, formatter.date(from: "2026-08-07T00:00:00Z"))
    }

    func test_toDomain_fractionalSecondsCreatedAt_parsesSuccessfullyIgnoringFraction() throws {
        let dto = ConversationMessageDTO(
            id: 1, conversationId: 10, senderType: "USER", emotionType: nil,
            content: "내용", repliesToMessageId: nil, rootMessageId: nil, createdAt: "2026-08-07T00:00:00.500Z"
        )

        let createdAt = try XCTUnwrap(dto.toDomain()?.createdAt)

        // 소수초는 화면 표시에 필요 없어 잘라내고 파싱한다 — 초 단위까지만 일치하면 된다.
        let formatter = ISO8601DateFormatter()
        XCTAssertEqual(createdAt, formatter.date(from: "2026-08-07T00:00:00Z"))
    }

    func test_toDomain_invalidCreatedAt_returnsNil() {
        let dto = ConversationMessageDTO(
            id: 1, conversationId: 10, senderType: "USER", emotionType: nil,
            content: "내용", repliesToMessageId: nil, rootMessageId: nil, createdAt: "이상한값"
        )

        XCTAssertNil(dto.toDomain(), "createdAt 파싱에 실패하면 잘못된 시간으로 표시하는 대신 목록에서 제외되어야 함")
    }

    func test_toSentUserMessage_parsesCreatedAt() throws {
        let dto = makeDTO(senderType: "CHARACTER", emotionType: "JOY")

        let formatter = ISO8601DateFormatter()
        XCTAssertEqual(dto.toSentUserMessage().createdAt, formatter.date(from: "2026-08-07T00:00:00Z"))
    }

    func test_toDomain_userSender_mapsToUserMessage() {
        let dto = makeDTO(senderType: "USER", emotionType: nil)
        XCTAssertEqual(dto.toDomain()?.sender, .user)
    }

    func test_toDomain_characterSenderWithKnownEmotionType_mapsToCharacterMessage() {
        let cases: [(String, EmotionCharacter)] = [
            ("JOY", .joy), ("ANGER", .anger), ("ANXIETY", .anxiety),
            ("GRUMPY", .prickly), ("SADNESS", .sadness), ("QUIRKY", .quirky),
        ]
        for (serverValue, expected) in cases {
            let dto = makeDTO(senderType: "CHARACTER", emotionType: serverValue)
            XCTAssertEqual(dto.toDomain()?.sender, .character(expected), "서버 값 \(serverValue)")
        }
    }

    func test_toDomain_characterSenderWithUnknownEmotionType_returnsNil() {
        let dto = makeDTO(senderType: "CHARACTER", emotionType: "UNKNOWN_TYPE")
        XCTAssertNil(dto.toDomain())
    }

    func test_toDomain_unknownSenderType_returnsNil() {
        let dto = makeDTO(senderType: "SYSTEM", emotionType: nil)
        XCTAssertNil(dto.toDomain())
    }

    func test_toSentUserMessage_alwaysMapsToUserRegardlessOfSenderType() {
        let dto = makeDTO(senderType: "CHARACTER", emotionType: "JOY")
        XCTAssertEqual(dto.toSentUserMessage().sender, .user)
    }

    func test_decode_fromServerShapedJSON_succeeds() throws {
        let json = """
        {"id":1,"conversationId":10,"senderType":"CHARACTER","emotionType":"JOY","content":"반가워","repliesToMessageId":5,"rootMessageId":5,"createdAt":"2026-08-07T00:00:00Z"}
        """
        let dto = try JSONDecoder().decode(ConversationMessageDTO.self, from: Data(json.utf8))
        XCTAssertEqual(dto.id, 1)
        XCTAssertEqual(dto.toDomain()?.sender, .character(.joy))
    }
}
