//
//  BubbleWidthLayout.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import SwiftUI

/// 콘텐츠의 intrinsic 너비와 `maxWidth` 중 작은 값을 버블의 크기로 사용한다.
///
/// `.frame(maxWidth:)`만으로는 부모 HStack이 공간을 분배하는 방식에 따라
/// 짧은 메시지에서도 버블이 `maxWidth`까지 늘어날 수 있다. 이 Layout은
/// 부모가 어떤 크기를 제안하든 `proposal`을 무시하고 항상
/// `min(intrinsicWidth, maxWidth)`를 스스로 계산해 보고하므로, 부모 HStack의
/// Spacer가 남는 공간을 온전히 가져가고 버블은 콘텐츠 크기만큼만 차지한다.
struct BubbleWidthLayout: Layout {
    let maxWidth: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        guard let subview = subviews.first else {
            return .zero
        }

        let idealWidth = subview.sizeThatFits(.unspecified).width
        let targetWidth = min(idealWidth, maxWidth)

        // 결정된 targetWidth로 다시 측정한다. maxWidth를 초과했던 콘텐츠는
        // 여기서 targetWidth 폭에 맞춰 wrapping된다.
        return subview.sizeThatFits(ProposedViewSize(width: targetWidth, height: nil))
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard let subview = subviews.first else {
            return
        }

        subview.place(
            at: bounds.origin,
            anchor: .topLeading,
            proposal: ProposedViewSize(width: bounds.width, height: bounds.height)
        )
    }
}
