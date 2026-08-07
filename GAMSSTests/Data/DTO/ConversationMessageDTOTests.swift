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

    func test_toDomain_userSender_mapsToUserMessage() {
        let dto = makeDTO(senderType: "USER", emotionType: nil)
        XCTAssertEqual(dto.toDomain()?.sender, .user)
    }

    func test_toDomain_characterSenderWithKnownEmotionType_mapsToCharacterMessage() {
        let cases: [(String, EmotionCharacter)] = [
            ("JOY", .joy), ("ANGER", .anger), ("ANXIETY", .anxiety),
            ("GRUMPY", .prickly), ("WARM", .warm), ("QUIRKY", .quirky),
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
