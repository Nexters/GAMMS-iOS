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
    var size: CGFloat = 24

    var body: some View {
        Image(emotion.avatarImageName)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
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
