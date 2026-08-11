//
//  EmotionCharacter.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

/// 대화 상대로 등장하는 페르소나 캐릭터 6종.
/// EmotionCharacter`는 서버가 대화 메시지의 발신자로 내려주는
/// UI/대화 도메인의 캐릭터 식별자다.
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
