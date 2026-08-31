//
//  SearchChatResponseDTO.swift
//  GAMSS
//
//  Created by 이건준 on 8/15/26.
//

import Foundation

struct SearchChatResponseDTO: Decodable {
    let content: [SearchContent]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int

    func toDomain() -> ConversationPage {
        ConversationPage(
            items: content.compactMap { $0.toDomain() },
            page: page,
            size: size,
            totalPages: totalPages
        )
    }
}

struct SearchContent: Decodable {
    let conversationId: Int
    let title: String
    let status: String
    let createdAt: String

    func toDomain() -> ConversationSummary? {
        guard let createdAtDate = ISO8601FlexibleParser.date(from: createdAt) else { return nil }
        return ConversationSummary(
            id: conversationId,
            title: title,
            createdAt: createdAtDate
        )
    }
}
