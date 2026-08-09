//
//  ConversationMessageDTO.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import Foundation

/// 서버 필드명과 1:1 (Android ConversationMessage.kt 기준). senderType이 "CHARACTER"일 때만
/// emotionType이 채워진다. senderType이 알 수 없거나 emotionType을 못 알아보면 toDomain()이
/// nil을 반환 — 잘못된 주체로 그리는 것보다 목록에서 제외하는 쪽을 택한다.
struct ConversationMessageDTO: Decodable {
    let id: Int
    let conversationId: Int
    let senderType: String
    let emotionType: String?
    let content: String
    let repliesToMessageId: Int?
    let rootMessageId: Int?
    let createdAt: String

    private static let serverTypeToCharacter: [String: EmotionCharacter] = [
        "JOY": .joy, "ANGER": .anger, "ANXIETY": .anxiety,
        "GRUMPY": .prickly, "WARM": .sadness, "QUIRKY": .quirky,
    ]

    func toDomain() -> Message? {
        let sender: MessageSender
        switch senderType {
        case "USER":
            sender = .user
        case "CHARACTER":
            guard let character = Self.serverTypeToCharacter[emotionType ?? ""] else { return nil }
            sender = .character(character)
        default:
            return nil
        }
        return Message(id: id, conversationId: conversationId, sender: sender, content: content, repliesToMessageId: repliesToMessageId)
    }

    /// 방금 보낸 사용자 메시지 응답 전용 — 항상 .user로 간주한다.
    func toSentUserMessage() -> Message {
        Message(id: id, conversationId: conversationId, sender: .user, content: content, repliesToMessageId: repliesToMessageId)
    }
}
