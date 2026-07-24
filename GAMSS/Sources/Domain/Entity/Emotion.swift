//
//  Emotion.swift
//  GAMSS
//
//  Created by cchanmi on 7/24/26.
//

enum Emotion: String, CaseIterable, Equatable {
    case angry
    case happy
    case anxious
    case embarrassed
    case sad
    case heartache
}

extension Emotion {
    /// id2label.json` 출력 순서 그대로.
    /// {0: angry, 1: anxious, 2: embarrassed, 3: happy, 4: heartache, 5: sad}.
    /// Core ML 모델 출력(`probabilities[i]`)의 인덱스 i가 이 배열의 i번째 값에 대응함.
    static let orderedByModelIndex: [Emotion] = [
        .angry, .anxious, .embarrassed, .happy, .heartache, .sad,
    ]
}
