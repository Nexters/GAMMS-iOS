//
//  MessageBubbleView.swift
//  GAMSS
//
//  Created by cchanmi on 8/12/26.
//

import SwiftUI

/// 채팅 메시지 한 건을 sent(사용자)/received(캐릭터)/receivedReply(캐릭터의 인용 답장)
/// 스타일로 렌더링한다.
struct MessageBubbleView: View {
    let message: Message
    let quotedMessage: Message?
    let maxWidth: CGFloat

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.spacing100) {
            switch message.sender {
            case .user:
                Spacer(minLength: 0)
                timestamp
                bubble

            case let .character(emotion):
                VStack(alignment: .leading, spacing: Spacing.spacing050) {
                    header(for: emotion)
                    HStack(alignment: .bottom, spacing: Spacing.spacing100) {
                        bubble
                        timestamp
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }

    private func header(for emotion: EmotionCharacter) -> some View {
        HStack(spacing: Spacing.spacing075) {
            EmotionAvatarView(emotion: emotion)
            Text(emotion.displayName)
                .typography(.body4Medium)
                .foregroundStyle(Color.colorGray800)
        }
    }

    private var quotedHeaderLabel: String? {
        guard let quotedMessage else { return nil }
        return QuotedReplyHeader.label(forQuotedSender: quotedMessage.sender)
    }

    private var bubble: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing050) {
            if let quotedHeaderLabel, let quotedMessage {
                // 이 인용 헤더 블록은 light 버블(수신/캐릭터) 배경을 전제로 한
                // colorGray950/colorGray500 색상을 쓴다. 현재는 사용자가 항상
                // repliesToMessageId: nil로 보내기 때문에 user(sent, dark) 버블에서는
                // 도달하지 않지만, 추후 sentReply 기능으로 사용자 버블에서도 인용 블록을
                // 표시하게 되면 어두운 배경 위에서 거의 안 보이게 되므로 그때 색상을
                // 재검토해야 한다.
                Text(quotedHeaderLabel)
                    .typography(.body5Medium)
                    .foregroundStyle(Color.colorGray950)
                Text(quotedMessage.content)
                    .typography(.body4Medium)
                    .foregroundStyle(Color.colorGray500)
                Rectangle()
                    .fill(Color.colorGray200)
                    .frame(height: 1)
            }

            Text(message.content)
                .typography(.body4Medium)
                .foregroundStyle(bodyTextColor)
        }
        .padding(.vertical, Spacing.spacing100)
        .padding(.horizontal, Spacing.spacing200)
        .frame(maxWidth: maxWidth, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.radius200)
                .fill(bubbleBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.radius200)
                .strokeBorder(Color.colorGray950, lineWidth: 1)
        )
    }

    private var timestamp: some View {
        Text(MessageTimestampFormatter.string(from: message.createdAt))
            .typography(.body5Regular)
            .foregroundStyle(Color.colorGray600)
    }

    private var bodyTextColor: Color {
        switch message.sender {
        case .user: Color.colorGray025
        case .character: Color.colorGray950
        }
    }

    private var bubbleBackground: Color {
        switch message.sender {
        case .user: Color.colorGray900
        case .character: Color.colorGray025
        }
    }
}

#Preview("sent") {
    MessageBubbleView(
        message: Message(id: 1, conversationId: 1, sender: .user, content: "안녕하세요, 오늘 하루도 힘내봐요!", repliesToMessageId: nil, createdAt: Date()),
        quotedMessage: nil,
        maxWidth: 260
    )
    .padding()
}

#Preview("received") {
    MessageBubbleView(
        message: Message(id: 2, conversationId: 1, sender: .character(.joy), content: "안녕! 오늘도 행복한 하루~!", repliesToMessageId: 1, createdAt: Date()),
        quotedMessage: nil,
        maxWidth: 260
    )
    .padding()
}

#Preview("receivedReply") {
    let original = Message(id: 2, conversationId: 1, sender: .character(.anxiety), content: "안녕하세용", repliesToMessageId: 1, createdAt: Date())
    return MessageBubbleView(
        message: Message(id: 3, conversationId: 1, sender: .character(.prickly), content: "뭐가안녕한데 ㅋㅋ", repliesToMessageId: 2, createdAt: Date()),
        quotedMessage: original,
        maxWidth: 260
    )
    .padding()
}
