//
//  CommentRevealPolicyTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import XCTest
@testable import GAMSS

final class CommentRevealPolicyTests: XCTestCase {
    func test_nextGapSeconds_isAlwaysWithinOneToThreeSeconds() {
        for _ in 0..<200 {
            let gap = CommentRevealPolicy.nextGapSeconds()
            XCTAssertGreaterThanOrEqual(gap, CommentRevealPolicy.minSeconds)
            XCTAssertLessThanOrEqual(gap, CommentRevealPolicy.maxSeconds)
        }
    }
}
