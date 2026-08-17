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
}

struct SearchContent: Decodable {
    let conversationId: Int
    let title: String
    let status: String
    let createdAt: String
}
