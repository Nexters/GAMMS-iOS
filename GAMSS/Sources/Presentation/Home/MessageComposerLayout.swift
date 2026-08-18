//
//  MessageComposerLayout.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import CoreGraphics

/// 홈 화면 메시지 입력창의 높이. Figma 지정값 — collapsed(포커스 없음)/expanded(포커스 있음)
/// 딱 두 단계로 고정되며, 텍스트가 늘어나도 이 높이 자체가 커지지는 않고 TextEditor 내부
/// 스크롤로 처리된다.
enum MessageComposerLayout {
    /// 포커스가 없을 때(collapsed)의 고정 높이.
    static let collapsedHeight: CGFloat = 116
    /// 포커스가 있을 때(expanded)의 고정 높이.
    static let expandedHeight: CGFloat = 150

    static func height(isExpanded: Bool) -> CGFloat {
        isExpanded ? expandedHeight : collapsedHeight
    }
}
