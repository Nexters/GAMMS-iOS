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

    /// 전송 중인 내 메시지 전용 — 항상 사용자 발신.
    init(pendingUserMessage: PendingUserMessage, maxWidth: CGFloat) {
        self.sender = .user
        self.content = pendingUserMessage.content
        self.createdAt = pendingUserMessage.sentAt
        self.quotedHeaderLabel = pendingUserMessage.quotedSenderLabel
        self.quotedContent = pendingUserMessage.quotedContent
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
                        .foregroundStyle(quotedHeaderLabelColor)
                    Text(quotedContent)
                        .typography(.body4Medium)
                        .foregroundStyle(quotedContentColor)
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

    /// 캐릭터(밝은 배경) 버블은 기존 색 그대로, 사용자(어두운 배경) 버블은 본문 텍스트와 같은
    /// 밝은 색으로 — 그대로 두면 어두운 배경에 어두운 글자가 겹쳐 안 보이게 된다.
    private var quotedHeaderLabelColor: Color {
        switch sender {
        case .user: Color.colorGray025
        case .character: Color.colorGray950
        }
    }

    private var quotedContentColor: Color {
        switch sender {
        case .user: Color.colorGray200
        case .character: Color.colorGray500
        }
    }

    private var bubbleBackground: Color {
        switch sender {
        case .user: Color.colorGray900
        case .character: Color.colorGray025
        }
    }
}

#Preview("sentReply") {
    MessageBubbleView(
        pendingUserMessage: PendingUserMessage(
            content: "고마워",
            sentAt: Date(),
            quotedSenderLabel: "불안에게 답장",
            quotedContent: "안녕하세용"
        ),
        maxWidth: 260
    )
    .padding()
}
