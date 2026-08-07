//
//  SaveMessageRequestDTO.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import Foundation

/// nil 필드는 직렬화에서 키 자체가 빠져야 한다(conversationId 생략 = 새 채팅방). Swift
/// JSONEncoder는 기본적으로 nil을 "key": null로 인코딩하므로, encode(to:)를 커스텀 구현해서
/// Kotlin의 encodeDefaults=false와 동일하게 맞춘다.
struct SaveMessageRequestDTO: Encodable {
    let content: String
    let conversationId: Int?
    let repliesToMessageId: Int?
    let currentConversationSummary: String?

    private enum CodingKeys: String, CodingKey {
        case content, conversationId, repliesToMessageId, currentConversationSummary
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(content, forKey: .content)
        try container.encodeIfPresent(conversationId, forKey: .conversationId)
        try container.encodeIfPresent(repliesToMessageId, forKey: .repliesToMessageId)
        try container.encodeIfPresent(currentConversationSummary, forKey: .currentConversationSummary)
    }
}
