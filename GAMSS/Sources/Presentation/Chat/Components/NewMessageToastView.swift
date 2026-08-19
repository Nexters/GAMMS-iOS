//
//  NewMessageToastView.swift
//  GAMSS
//
//  Created by cchanmi on 8/18/26.
//

import SwiftUI

struct NewMessageToastView: View {
    let message: Message
    let action: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Spacer(minLength: Spacing.spacing700)

            Button(action: action) {
                HStack(spacing: Spacing.spacing075) {
                    if case let .character(emotion) = message.sender {
                        EmotionAvatarView(emotion: emotion, size: 16)
                        Text(emotion.displayName)
                            .typography(.body5Medium)
                            .foregroundStyle(Color.colorGray025)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    }

                    Text(message.content)
                        .typography(.body4Medium)
                        .foregroundStyle(Color.colorGray200)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .padding(.horizontal, Spacing.spacing200)
                .frame(height: 34)
                .background(Color.colorGray800)
                .overlay(Rectangle().strokeBorder(Color.colorGray950, lineWidth: 1))
                .shadow(color: Color.colorBlack.opacity(0.25), radius: 30)
            }

            Spacer(minLength: Spacing.spacing700)
        }
        .accessibilityLabel("\(senderLabel) 새 메시지: \(message.content)")
    }

    private var senderLabel: String {
        switch message.sender {
        case let .character(emotion): emotion.displayName
        case .user: ""
        }
    }
}

#Preview {
    NewMessageToastView(
        message: Message(id: 1, conversationId: 1, sender: .character(.prickly), content: "안녕하세요! 오늘 하루는 어땠어요? 궁금해서 물어봐요", repliesToMessageId: nil, createdAt: Date()),
        action: {}
    )
    .padding(.vertical, Spacing.spacing300)
    .background(Color.colorGray100)
}
