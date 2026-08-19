//
//  TokenUsage.swift
//  GAMSS
//
//  Created by cchanmi on 8/18/26.
//

struct TokenUsage: Equatable {
    let usedTokens: Int
    let dailyLimit: Int
    let exceeded: Bool

    var percent: Int {
        guard dailyLimit > 0 else { return 0 }
        return min(100, (usedTokens * 100) / dailyLimit)
    }
}
