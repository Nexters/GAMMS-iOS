//
//  CreateMessageRequestDTO.swift
//  GAMSS
//
//  Created by 이건준 on 8/8/26.
//

import Foundation

struct CreateMessageRequestDTO: Encodable {
    let conversationId: Int
    let content: String
    let repliesMessageId: Int
    let currentConversationSummary: String
    let excludeCharacters: [String]
}
