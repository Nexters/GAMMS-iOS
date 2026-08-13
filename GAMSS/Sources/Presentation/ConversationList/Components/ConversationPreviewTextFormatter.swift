//
//  ConversationPreviewTextFormatter.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import Foundation

/// 대화방 목록 카드의 미리보기 텍스트를 최대 길이로 잘라낸다. `.lineLimit(1)`만으로는 폰트/기기별로
/// 실제 잘리는 글자 수가 달라질 수 있어, 명시적으로 글자 수를 잘라내는 쪽을 우선한다.
enum ConversationPreviewTextFormatter {
    static let maxLength = 25

    static func truncated(_ text: String) -> String {
        guard text.count > maxLength else { return text }
        return String(text.prefix(maxLength)) + "…"
    }
}
