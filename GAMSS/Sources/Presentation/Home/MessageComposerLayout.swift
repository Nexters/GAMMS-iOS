//
//  MessageComposerLayout.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import CoreGraphics

/// 홈 화면 메시지 입력창의 높이 계산을 담당한다. 입력이 없을 때는 한 줄 높이로 고정되고,
/// 입력이 늘어나면 콘텐츠 높이만큼 자라나되 collapsedHeight~maxExpandedHeight 범위로 clamp된다.
enum MessageComposerLayout {
    /// 입력이 비어있을 때(collapsed)의 고정 높이. 매직넘버 대신 한 줄 타이포그래피 높이 +
    /// 상하 패딩으로 산출한다.
    static let collapsedHeight: CGFloat = Typography.body3Regular.metrics.lineHeight + Spacing.spacing300 * 2

    /// 입력이 늘어나도(expanded) 더 이상 자라지 않는 최대 높이. 이 이상은 TextEditor 자체
    /// 스크롤로 처리한다.
    static let maxExpandedHeight: CGFloat = 220

    /// 측정된 텍스트 콘텐츠 높이를 collapsedHeight~maxExpandedHeight 범위로 clamp한다.
    static func clampedHeight(forMeasuredContentHeight measuredContentHeight: CGFloat) -> CGFloat {
        min(max(measuredContentHeight, collapsedHeight), maxExpandedHeight)
    }
}
