//
//  FetchCardsByDateResponseDTO.swift
//  GAMSS
//
//  Created by 이건준 on 8/20/26.
//

import Foundation

struct FetchCardsByDateResponseDTO: Decodable {
    let id: Int
    let conversationId: Int
    let emotion: String
    let emotionLabel: String
    let summary: String
    let date: String
}
