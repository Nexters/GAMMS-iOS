//
//  FetchMonthlyCardsResponseDTO.swift
//  GAMSS
//
//  Created by 이건준 on 8/19/26.
//

import Foundation

struct FetchMonthlyCardsResponseDTO: Decodable {
    let date: String
    let emotions: [String]
}
