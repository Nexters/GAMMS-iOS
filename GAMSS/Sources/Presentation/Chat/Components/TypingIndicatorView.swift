//
//  TypingIndicatorView.swift
//  GAMSS
//
//  Created by cchanmi on 8/18/26.
//

import Lottie
import SwiftUI

/// 다음 순서로 답장할 캐릭터가 "입력 중"임을 로티 애니메이션으로 보여준다. 서버 응답(코멘트
/// 목록)이 이미 도착해 다음 발신자를 알고 있는 상태에서만 쓰인다 — MessageBubbleView의
/// 캐릭터(수신) 케이스와 같은 헤더(아바타+이름) 구조를 그대로 따르고, 버블 내용만 텍스트
/// 대신 로티로 바꾼다.
struct TypingIndicatorView: View {
    /// ChatView가 스크롤 대상으로 삼는 고정 id.
    static let scrollAnchorID = "typingIndicator"

    let emotion: EmotionCharacter

    /// 로티 원본 비율을 유지한 표시 크기.
    private let animationSize = CGSize(width: 54, height: 36)

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.spacing100) {
            VStack(alignment: .leading, spacing: Spacing.spacing050) {
                header

                bubble
                    .padding(.leading, MessageBubbleLayout.receivedIndent)
            }

            Spacer(minLength: 0)
        }
    }

    private var header: some View {
        HStack(spacing: Spacing.spacing075) {
            EmotionAvatarView(emotion: emotion)
            Text(emotion.displayName)
                .typography(.body4Medium)
                .foregroundStyle(Color.colorGray800)
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
    TypingIndicatorView(emotion: .sadness)
        .padding()
}
