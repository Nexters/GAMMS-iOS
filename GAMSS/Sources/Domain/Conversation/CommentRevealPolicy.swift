//
//  CommentRevealPolicy.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

enum CommentRevealPolicy {
    static let minSeconds = 1.0
    static let maxSeconds = 3.0

    /// 답장 하나가 노출된 직후, 다음 캐릭터의 "입력 중" 표시가 뜨기 전까지 쉬는 짧은 정적
    /// 구간. 이게 없으면 이전 캐릭터의 말풍선이 뜨는 순간과 동시에 다음 캐릭터의 입력중
    /// 표시가 나타나 끼어드는 것처럼 보인다.
    static let postRevealGapSeconds = 0.4

    static func nextGapSeconds() -> Double {
        .random(in: minSeconds...maxSeconds)
    }
}
