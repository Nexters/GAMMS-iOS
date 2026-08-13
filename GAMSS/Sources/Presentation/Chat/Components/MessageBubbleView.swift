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
                    .padding(.leading, MessageBubbleLayout.receivedIndent)
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
        BubbleWidthLayout(maxWidth: bubbleMaxWidth) {
            VStack(alignment: .leading, spacing: Spacing.spacing050) {
                if let quotedHeaderLabel, let quotedMessage {
                    Text(quotedHeaderLabel)
                        .typography(.body5Medium)
                        .foregroundStyle(Color.colorGray950)
                    Text(quotedMessage.content)
                        .typography(.body4Medium)
                        .foregroundStyle(Color.colorGray500)
                        .lineLimit(1)
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
        }
        .background(bubbleBackground)
        .overlay(
            Rectangle()
                .strokeBorder(Color.colorGray950, lineWidth: 1)
        )
    }

    private var bubbleMaxWidth: CGFloat {
        switch message.sender {
        case .user: maxWidth
        case .character: MessageBubbleLayout.receivedBubbleMaxWidth(maxWidth: maxWidth)
        }
    }

    private var timestamp: some View {
        Text(MessageTimestampFormatter.string(from: message.createdAt))
            .typography(.body6Regular)
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
