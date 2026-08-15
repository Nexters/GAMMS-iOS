//
//  MessageBubbleView.swift
//  GAMSS
//
//  Created by cchanmi on 8/12/26.
//

import SwiftUI

/// 채팅 메시지 한 건을 sent(사용자)/received(캐릭터)/receivedReply(캐릭터의 인용 답장)
/// 스타일로 렌더링한다. 렌더링에 필요한 필드만 저장해서, 확정된 `Message`든 아직 서버 응답을
/// 기다리는 `PendingUserMessage`든 같은 방식으로 그릴 수 있다.
struct MessageBubbleView: View {
    private let sender: MessageSender
    private let content: String
    private let createdAt: Date
    private let quotedHeaderLabel: String?
    private let quotedContent: String?
    private let maxWidth: CGFloat

    init(message: Message, quotedMessage: Message?, maxWidth: CGFloat) {
        self.sender = message.sender
        self.content = message.content
        self.createdAt = message.createdAt
        self.quotedHeaderLabel = quotedMessage.flatMap { QuotedReplyHeader.label(forQuotedSender: $0.sender) }
        self.quotedContent = quotedMessage?.content
        self.maxWidth = maxWidth
    }

    /// 전송 중인 내 메시지 전용 — 항상 사용자 발신, 인용 답장은 없다.
    init(pendingUserMessage: PendingUserMessage, maxWidth: CGFloat) {
        self.sender = .user
        self.content = pendingUserMessage.content
        self.createdAt = pendingUserMessage.sentAt
        self.quotedHeaderLabel = nil
        self.quotedContent = nil
        self.maxWidth = maxWidth
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.spacing100) {
            switch sender {
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

    private var bubble: some View {
        BubbleWidthLayout(maxWidth: bubbleMaxWidth) {
            VStack(alignment: .leading, spacing: Spacing.spacing050) {
                if let quotedHeaderLabel, let quotedContent {
                    Text(quotedHeaderLabel)
                        .typography(.body5Medium)
                        .foregroundStyle(Color.colorGray950)
                    Text(quotedContent)
                        .typography(.body4Medium)
                        .foregroundStyle(Color.colorGray500)
                        .lineLimit(1)
                    Rectangle()
                        .fill(Color.colorGray200)
                        .frame(height: 1)
                }

                Text(content)
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
        switch sender {
        case .user: maxWidth
        case .character: MessageBubbleLayout.receivedBubbleMaxWidth(maxWidth: maxWidth)
        }
    }

    private var timestamp: some View {
        Text(MessageTimestampFormatter.string(from: createdAt))
            .typography(.body6Regular)
            .foregroundStyle(Color.colorGray600)
    }

    private var bodyTextColor: Color {
        switch sender {
        case .user: Color.colorGray025
        case .character: Color.colorGray950
        }
    }

    private var bubbleBackground: Color {
        switch sender {
        case .user: Color.colorGray900
        case .character: Color.colorGray025
        }
    }
}
