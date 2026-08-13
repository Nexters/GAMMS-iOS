//
//  EmotionCharacterServerKeyMapping.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

/// `EmotionCharacter`(Domain) ↔ 서버 wire-format 문자열 간 양방향 매핑.
/// 서버 키 문자열은 Data 레이어 관심사라 Domain 엔티티(`EmotionCharacter`)에는 두지 않는다 —
/// `ConversationMessageDTO`(디코딩, senderType이 CHARACTER일 때 emotionType 파싱)와
/// `DefaultConversationRepository`(인코딩, 메시지 전송 시 excludeCharacters 필드) 양쪽이
/// 이 하나의 매핑을 공유한다.
enum EmotionCharacterServerKeyMapping {
    /// 서버 키 → `EmotionCharacter`. 이 딕셔너리가 유일한 진실 공급원이며, 반대 방향은
    /// 여기서 파생한다.
    // "WARM"이 아니라 "SADNESS"가 맞는 서버 키다 — 실제 응답으로 확인함.
    private static let serverKeyToCharacter: [String: EmotionCharacter] = [
        "JOY": .joy, "ANGER": .anger, "ANXIETY": .anxiety,
        "GRUMPY": .prickly, "SADNESS": .sadness, "QUIRKY": .quirky,
    ]

    private static let characterToServerKey: [EmotionCharacter: String] = Dictionary(
        uniqueKeysWithValues: serverKeyToCharacter.map { ($1, $0) }
    )

    static func character(forServerKey key: String) -> EmotionCharacter? {
        serverKeyToCharacter[key]
    }

    static func serverKey(for character: EmotionCharacter) -> String {
        // characterToServerKey는 serverKeyToCharacter의 6개 키 전부를 반전시켜 만들어서
        // EmotionCharacter의 6개 케이스 모두가 항상 채워져 있다 — force unwrap이 안전하다.
        characterToServerKey[character]!
    }
}
