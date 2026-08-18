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
        Button(action: action) {
            HStack(spacing: Spacing.spacing100) {
                Text(senderLabel)
                    .typography(.body5Medium)
                    .foregroundStyle(Color.colorGray950)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)

                Text(message.content)
                    .typography(.body4Medium)
                    .foregroundStyle(Color.colorGray500)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.horizontal, Spacing.spacing300)
            .padding(.vertical, Spacing.spacing150)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.colorGray025)
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
}
