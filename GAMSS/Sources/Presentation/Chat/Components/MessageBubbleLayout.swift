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

    static func maxBubbleWidth(availableWidth: CGFloat, containerPadding: CGFloat) -> CGFloat {
        availableWidth - oppositeMargin - containerPadding
    }
}
