//
//  QuotedReplyHeader.swift
//  GAMSS
//
//  Created by cchanmi on 8/12/26.
//

/// 인용 답장 버블 상단의 "OOO에게 답장" 라벨을 계산한다.
///
/// 캐릭터의 1차 댓글은 repliesToMessageId가 거의 항상 사용자 메시지를 가리키는데
/// (대화가 어디서 시작됐는지 나타내는 앵커 포인터), 이 경우는 헤더를 보여주지 않는 게
/// 기본 경로다. 헤더는 캐릭터가 다른 캐릭터의 메시지를 인용하는 실제 스레드 답장에서만 보인다.
enum QuotedReplyHeader {
    static func label(forQuotedSender sender: MessageSender) -> String? {
        switch sender {
        case let .character(emotion):
            return "\(emotion.displayName)에게 답장"
        case .user:
            return nil
        }
    }
}
