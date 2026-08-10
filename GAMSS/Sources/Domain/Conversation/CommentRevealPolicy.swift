//
//  CommentRevealPolicy.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

enum CommentRevealPolicy {
    static let minSeconds = 1.0
    static let maxSeconds = 3.0

    static func nextGapSeconds() -> Double {
        .random(in: minSeconds...maxSeconds)
    }
}
