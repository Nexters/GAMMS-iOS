//
//  PendingFirstMessage.swift
//  GAMSS
//
//  Created by cchanmi on 8/19/26.
//

/// 홈에서 아직 서버에 보내지 않은 첫 메시지를 채팅 화면으로 넘길 때 쓰는 타입. 화면 전환은
/// 즉시 일어나고, 실제 전송은 ChatViewModel이 화면 진입 직후 이 값으로 자동 시작한다.
struct PendingFirstMessage: Hashable {
    let content: String
    let excludedCharacters: Set<EmotionCharacter>
}
