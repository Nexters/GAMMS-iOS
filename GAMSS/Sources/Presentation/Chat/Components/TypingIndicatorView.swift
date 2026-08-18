//
//  TypingIndicatorView.swift
//  GAMSS
//
//  Created by cchanmi on 8/18/26.
//

import Lottie
import SwiftUI

/// 캐릭터 답장을 기다리는 동안 보여주는 "입력 중" 표시. 어떤 캐릭터가 다음에 답장할지는
/// 응답이 와야 알 수 있으므로 특정 캐릭터를 지목하지 않는 중립 버블이다.
/// MessageBubbleView의 캐릭터(수신) 케이스와 같은 2단 구조(헤더 텍스트 + 버블)를 따르되
/// 아바타만 뺀다.
struct TypingIndicatorView: View {
    /// ChatView가 스크롤 대상으로 삼는 고정 id.
    static let scrollAnchorID = "typingIndicator"

    private let animationSize = CGSize(width: 54, height: 36)

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.spacing100) {
            VStack(alignment: .leading, spacing: Spacing.spacing050) {
                Text("입력 중")
                    .typography(.body4Medium)
                    .foregroundStyle(Color.colorGray800)

                bubble
            }
            .padding(.leading, MessageBubbleLayout.receivedIndent)

            Spacer(minLength: 0)
        }
    }

    private var bubble: some View {
        LottieView(animation: .named("typingIndicator"))
            .looping()
            .resizable()
            .scaledToFit()
            .frame(width: animationSize.width, height: animationSize.height)
            .background(Color.colorGray025)
            .overlay(
                Rectangle()
                    .strokeBorder(Color.colorGray950, lineWidth: 1)
            )
    }
}

#Preview {
    TypingIndicatorView()
        .padding()
}
