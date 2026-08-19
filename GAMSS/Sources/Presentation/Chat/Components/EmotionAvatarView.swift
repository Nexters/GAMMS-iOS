//
//  EmotionAvatarView.swift
//  GAMSS
//
//  Created by cchanmi on 8/12/26.
//

import SwiftUI

/// 캐릭터 프로필 아바타.
struct EmotionAvatarView: View {
    let emotion: EmotionCharacter

    var body: some View {
        Image(emotion.avatarImageName)
            .resizable()
            .scaledToFill()
            .frame(width: 24, height: 24)
            .clipShape(Circle())
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
