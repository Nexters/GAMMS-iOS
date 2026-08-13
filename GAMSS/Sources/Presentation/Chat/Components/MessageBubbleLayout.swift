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

    /// 수신 버블 행을 오른쪽으로 밀어내는 들여쓰기. 두 곳에서 함께 써야 값이 어긋나지 않는다:
    /// MessageBubbleView가 `.padding(.leading:)`로 행을 실제로 밀어내는 곳, 그리고
    /// `receivedBubbleMaxWidth`가 그만큼을 버블 최대 너비에서 미리 빼는 곳. 이 값을 바꾸면
    /// 두 사용처 모두 자동으로 갱신되지만, 들여쓰기를 적용하는 방식 자체를 바꿀 때는(예:
    /// 아바타 폭 기반으로 변경) 두 곳을 함께 확인해야 한다.
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
