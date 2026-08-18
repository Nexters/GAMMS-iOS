//
//  TokenUsageResponseDTO.swift
//  GAMSS
//
//  Created by cchanmi on 8/18/26.
//

import Foundation

struct TokenUsageResponseDTO: Decodable {
    let usedTokens: Int
    let dailyLimit: Int
    let exceeded: Bool

    func toDomain() -> TokenUsage {
        TokenUsage(usedTokens: usedTokens, dailyLimit: dailyLimit, exceeded: exceeded)
    }
}
