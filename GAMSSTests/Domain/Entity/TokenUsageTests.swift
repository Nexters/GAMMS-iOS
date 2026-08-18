//
//  TokenUsageTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/18/26.
//

import XCTest
@testable import GAMSS

final class TokenUsageTests: XCTestCase {
    func test_percent_computesFromUsedAndDailyLimit() {
        let usage = TokenUsage(usedTokens: 12000, dailyLimit: 100000, exceeded: false)

        XCTAssertEqual(usage.percent, 12)
    }

    func test_percent_truncatesDecimalRatherThanRounding() {
        let usage = TokenUsage(usedTokens: 999, dailyLimit: 1000, exceeded: false)

        XCTAssertEqual(usage.percent, 99)
    }

    func test_percent_clampsAtOneHundredWhenUsedExceedsLimit() {
        let usage = TokenUsage(usedTokens: 150000, dailyLimit: 100000, exceeded: true)

        XCTAssertEqual(usage.percent, 100)
    }

    func test_percent_dailyLimitZero_returnsZeroWithoutCrashing() {
        let usage = TokenUsage(usedTokens: 0, dailyLimit: 0, exceeded: false)

        XCTAssertEqual(usage.percent, 0)
    }
}
