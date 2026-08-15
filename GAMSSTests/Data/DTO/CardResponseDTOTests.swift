//
//  CardResponseDTOTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/15/26.
//

import XCTest
@testable import GAMSS

final class CardResponseDTOTests: XCTestCase {
    private func makeDTO(emotion: String? = "ANGER", date: String = "2026-07-23") -> CardResponseDTO {
        CardResponseDTO(id: 1, conversationId: 10, emotion: emotion, emotionLabel: "분노", summary: "요약", message: "메시지", date: date)
    }

    func test_toDomain_mapsAllFields() {
        let card = makeDTO().toDomain()

        XCTAssertEqual(card.id, 1)
        XCTAssertEqual(card.conversationId, 10)
        XCTAssertEqual(card.emotion, .anger)
        XCTAssertEqual(card.summary, "요약")
        XCTAssertEqual(card.message, "메시지")
    }

    func test_toDomain_nilEmotion_mapsToNilEmotion() {
        let card = makeDTO(emotion: nil).toDomain()

        XCTAssertNil(card.emotion)
    }

    func test_toDomain_unrecognizedEmotion_fallsBackToNilRatherThanDroppingCard() {
        let card = makeDTO(emotion: "UNKNOWN").toDomain()

        XCTAssertNil(card.emotion, "알 수 없는 감정 키는 카드 전체를 버리는 대신 emotion만 nil로 완화해야 함")
        XCTAssertEqual(card.summary, "요약")
    }

    func test_toDomain_validDate_parsesAsPlainDate() throws {
        let card = makeDTO(date: "2026-07-23").toDomain()

        XCTAssertEqual(card.date, PlainDateParser.date(from: "2026-07-23"))
    }

    func test_toDomain_invalidDate_fallsBackWithoutCrashing() {
        let card = makeDTO(date: "이상한값").toDomain()

        XCTAssertNotNil(card.date, "date 파싱에 실패해도 카드 자체는 만들어져야 함")
    }
}
