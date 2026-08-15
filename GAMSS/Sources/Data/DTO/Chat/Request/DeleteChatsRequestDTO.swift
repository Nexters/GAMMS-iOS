//
//  DeleteChatsRequestDTO.swift
//  GAMSS
//
//  Created by 이건준 on 8/15/26.
//

import Foundation

struct DeleteChatsRequestDTO: Encodable {
    let conversationIds: [Int]
}
