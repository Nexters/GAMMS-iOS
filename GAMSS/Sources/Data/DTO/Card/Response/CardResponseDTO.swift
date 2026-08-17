//
//  CardResponseDTO.swift
//  GAMSS
//
//  Created by cchanmi on 8/15/26.
//

import Foundation

/// emotionLabel은 서버가 내려주는 한국어 라벨이지만, 클라이언트는 이미 `EmotionCharacter.displayName`으로
/// 같은 문구를 만들 수 있어 emotionLabel은 쓰지 않고 emotion만 매핑한다.
struct CardResponseDTO: Decodable {
    let id: Int
    let conversationId: Int
    let emotion: String?
    let emotionLabel: String?
    let summary: String
    let message: String
    let date: String

    /// emotion 문자열이 있는데도 매핑에 실패하면(알 수 없는 새 서버 키 등) 카드 자체를 버리지
    /// 않고 nil emotion으로 완화한다 — summary/message는 여전히 유효한 데이터라서.
    /// date 파싱 실패도 마찬가지로 카드를 버리지 않고 오늘 날짜로 대체한다.
    func toDomain() -> Card {
        Card(
            id: id,
            conversationId: conversationId,
            emotion: emotion.flatMap { EmotionCharacterServerKeyMapping.character(forServerKey: $0) },
            summary: summary,
            message: message,
            date: PlainDateParser.date(from: date) ?? Date()
        )
    }
}
