//
//  EmotionAvatarView.swift
//  GAMSS
//
//  Created by cchanmi on 8/12/26.
//

import SwiftUI

/// 캐릭터 아바타 placeholder. 실제 캐릭터 이미지 에셋이 전달되기 전까지는 빈 원으로 표시한다.
/// emotion을 받아두는 이유는 이미지가 준비되면 캐릭터별 이미지로 교체하기 위함.
struct EmotionAvatarView: View {
    let emotion: EmotionCharacter

    var body: some View {
        Circle()
            .fill(Color.colorWhite)
            .overlay(
                Circle().strokeBorder(Color.colorGray200, lineWidth: 1)
            )
            .frame(width: 24, height: 24)
    }
}

#Preview {
    HStack(spacing: Spacing.spacing200) {
        ForEach(Array(EmotionCharacter.allCases.enumerated()), id: \.offset) { _, emotion in
            EmotionAvatarView(emotion: emotion)
        }
    }
    .padding(Spacing.spacing300)
}
