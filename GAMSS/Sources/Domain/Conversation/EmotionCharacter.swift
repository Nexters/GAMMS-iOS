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

    /// 홈 화면 감정 선택 그리드 전용 짧은 라벨. `displayName`은 채팅 화면에 캐릭터 이름으로
    /// 쓰이는 문구("기쁨이" 등)라 감정 선택 UI("기쁨" 등, 어미 없음)에는 그대로 못 쓴다.
    var pickerLabel: String {
        switch self {
        case .joy: "기쁨"
        case .sadness: "슬픔"
        case .anger: "분노"
        case .anxiety: "불안"
        case .prickly: "까칠"
        case .quirky: "엉뚱"
        }
    }

    /// 홈 화면 감정 선택 그리드(2행 3열)에 표시할 순서. Figma 시안 순서를 그대로 따르며,
    /// `allCases` 선언 순서와는 다르다.
    static let pickerOrder: [EmotionCharacter] = [.anger, .quirky, .prickly, .joy, .sadness, .anxiety]
}
