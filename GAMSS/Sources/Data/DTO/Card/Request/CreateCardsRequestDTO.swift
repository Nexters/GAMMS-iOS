//
//  CreateCardsRequestDTO.swift
//  GAMSS
//
//  Created by 이건준 on 8/8/26.
//

import Foundation

struct CreateCardsRequestDTO: Encodable {
    let conversationId: Int
    let emotion: String
    let summary: String
}
