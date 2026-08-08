//
//  ConversationSummaryDTO.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

import Foundation

struct ConversationSummaryDTO: Decodable {
    let id: Int
    let title: String?
    let status: String
    let createdAt: String
    let updatedAt: String

    func toDomain() -> ConversationSummary {
        ConversationSummary(id: id, title: title, status: status, createdAt: createdAt)
    }
}
