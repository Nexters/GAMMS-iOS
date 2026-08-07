//
//  EmotionCharacter.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

enum EmotionCharacter: CaseIterable, Equatable {
    case joy, warm, anger, anxiety, prickly, quirky

    var displayName: String {
        switch self {
        case .joy: "기쁨"
        case .warm: "다정"
        case .anger: "분노"
        case .anxiety: "불안"
        case .prickly: "까칠"
        case .quirky: "엉뚱"
        }
    }
}
