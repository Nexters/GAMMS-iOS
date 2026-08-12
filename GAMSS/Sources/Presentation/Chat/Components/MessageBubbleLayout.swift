//
//  MessageBubbleLayout.swift
//  GAMSS
//
//  Created by cchanmi on 8/12/26.
//

import CoreGraphics

/// 메시지 버블의 최대 너비를 계산한다. 버블이 붙는 쪽 반대편에 최소 84px 여백을
/// 확보해야 한다는 디자인 규칙(Figma "bubble > maximum 영역")을 그대로 옮긴 것.
enum MessageBubbleLayout {
    static let oppositeMargin: CGFloat = 84
    static let receivedIndent: CGFloat = Spacing.spacing600

    static func maxBubbleWidth(availableWidth: CGFloat, containerPadding: CGFloat) -> CGFloat {
        // 첫 SwiftUI 레이아웃 패스에서 geometry.size.width가 0일 수 있어 결과가 음수가
        // 될 수 있다 — 음수 프레임 폭을 방지하기 위해 0으로 클램프한다.
        max(0, availableWidth - oppositeMargin - containerPadding)
    }

    static func receivedBubbleMaxWidth(maxWidth: CGFloat) -> CGFloat {
        max(0, maxWidth - receivedIndent)
    }
}
