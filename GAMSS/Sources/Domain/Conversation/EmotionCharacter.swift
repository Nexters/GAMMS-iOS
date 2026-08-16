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

    /// 대화 종료 카드의 타이틀 문구. 서버가 내려주는 값이 아니라 감정별 고정 가이드 문구다.
    var cardTitle: String {
        switch self {
        case .joy: "오늘 기~쁘네"
        case .sadness: "오늘 슬~프네"
        case .anger: "오늘 화~나네"
        case .anxiety: "오늘 불~안하네"
        case .prickly: "오늘 까~칠하네"
        case .quirky: "오늘 엉~뚱하네"
        }
    }

    /// 대화 종료 시 카드의 대표 감정으로 쓰인다. 캐릭터 답장에서 가장 많이 등장한 감정을 고르고,
    /// 동률이면 `allCases` 순서상 먼저 오는 쪽을 택해 항상 같은 결과가 나오게 한다.
    /// 캐릭터 답장이 하나도 없으면 nil(카드 emotion은 null로 전송).
    static func dominant(in messages: [Message]) -> EmotionCharacter? {
        var counts: [EmotionCharacter: Int] = [:]
        for message in messages {
            if case let .character(emotion) = message.sender {
                counts[emotion, default: 0] += 1
            }
        }
        guard !counts.isEmpty else { return nil }
        return allCases.max { (counts[$0] ?? 0) < (counts[$1] ?? 0) }
    }
}
