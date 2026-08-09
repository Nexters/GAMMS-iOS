//
//  CreateCommentRequestDTO.swift
//  GAMSS
//
//  Created by 이건준 on 8/8/26.
//

import Foundation

struct CreateCommentRequestDTO: Encodable {
    let messageId: Int
    let currentConversationSummary: String
}
