//
//  Message.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

enum MessageSender: Equatable {
    case user
    case character(EmotionCharacter)
}

struct Message: Identifiable, Equatable {
    let id: Int
    let conversationId: Int
    let sender: MessageSender
    let content: String
    let repliesToMessageId: Int?
}

enum CommentGenerationStatus: Equatable {
    case done, failed, limitExceeded
}

struct SentMessage: Equatable {
    let message: Message
    let commentStatus: CommentGenerationStatus
    let comments: [Message]
}
