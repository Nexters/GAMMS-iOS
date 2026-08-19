//
//  ScrollTarget.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

/// `ChatView`가 맨 아래로 스크롤할 때 실제로 어떤 항목을 앵커로 삼아야 하는지. View는 이 값을
/// 실제 SwiftUI 스크롤 앵커 id로 옮기기만 하고, "무엇이 마지막인지" 판단은 `ChatViewModel`이 한다.
enum ScrollTarget: Equatable {
    case typingIndicator
    case pendingUserMessage
    case message(Int)
}
