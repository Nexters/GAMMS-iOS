//
//  EmotionCharacter.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

enum EmotionCharacter: CaseIterable, Equatable {
    case joy, sadness, anger, anxiety, prickly, quirky

    var displayName: String {
        switch self {
        case .joy: "기쁨이"
        case .sadness: "슬픔이"
        case .anger: "분노"
        case .anxiety: "불안"
        case .prickly: "까칠이"
        case .quirky: "엉뚱이"
        }
    }
}
