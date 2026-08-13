//
//  ConversationMessageDTO.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import Foundation

/// 서버 필드명과 1:1 (Android ConversationMessage.kt 기준). senderType이 "CHARACTER"일 때만
/// emotionType이 채워진다. senderType이 알 수 없거나 emotionType을 못 알아보면 toDomain()이
/// nil을 반환 — 잘못된 주체로 그리는 것보다 목록에서 제외하는 쪽을 택한다. createdAt 파싱
/// 실패도 같은 이유로 nil을 반환한다.
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

    /// 화면에는 어차피 분 단위까지만 표시하므로(MessageTimestampFormatter), 소수초 정밀도는
    /// 필요 없다. 서버가 소수초 포함 타임스탬프(예: "2026-08-07T00:00:00.123Z")를 보내더라도
    /// 포매터를 두 개 두고 두 번 시도하는 대신, 소수초 부분만 잘라내고 포매터 하나로 파싱한다.
    /// ISO8601DateFormatter는 동시 접근 안전성이 문서화되어 있지 않아 인스턴스를 static으로
    /// 공유하지 않고 호출마다 새로 만든다 — 히스토리 로드와 메시지 전송 응답이 동시에 디코딩될
    /// 수 있기 때문.
    private static func parseCreatedAt(_ value: String) -> Date? {
        ISO8601DateFormatter().date(from: stripFractionalSeconds(value))
    }

    /// 소수초 부분(".123" 등)만 제거한다. 뒤에 타임존 지정자(Z/+/-)가 없어도 소수초 자체는
    /// 잘라내야 하므로, 그 존재를 전제하지 않고 "."부터 이어지는 숫자만 건너뛴다.
    private static func stripFractionalSeconds(_ value: String) -> String {
        guard let dotIndex = value.firstIndex(of: ".") else { return value }
        let afterDot = value[value.index(after: dotIndex)...]
        let suffixStart = afterDot.firstIndex(where: { !$0.isNumber }) ?? afterDot.endIndex
        return String(value[..<dotIndex]) + String(afterDot[suffixStart...])
    }

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
        guard let createdAtDate = Self.parseCreatedAt(createdAt) else { return nil }
        return Message(id: id, conversationId: conversationId, sender: sender, content: content, repliesToMessageId: repliesToMessageId, createdAt: createdAtDate)
    }

    /// 방금 보낸 사용자 메시지 응답 전용 — 항상 .user로 간주한다. createdAt 파싱에 실패해도
    /// (반환 타입이 옵셔널이 아니라) 크래시 없이 현재 시각으로 대체한다 — 서버가 방금 만든
    /// 응답이라 실제로 실패할 일은 거의 없는 안전망일 뿐이다.
    func toSentUserMessage() -> Message {
        Message(
            id: id,
            conversationId: conversationId,
            sender: .user,
            content: content,
            repliesToMessageId: repliesToMessageId,
            createdAt: Self.parseCreatedAt(createdAt) ?? Date()
        )
    }
}
