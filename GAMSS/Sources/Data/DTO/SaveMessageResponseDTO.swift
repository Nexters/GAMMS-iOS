//
//  SaveMessageResponseDTO.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import Foundation

struct SaveMessageResponseDTO: Decodable {
    let message: ConversationMessageDTO
    let commentStatus: String
    let comments: [ConversationMessageDTO]

    func toDomain() -> SentMessage {
        SentMessage(
            message: message.toSentUserMessage(),
            commentStatus: commentStatus.toCommentGenerationStatus(),
            comments: comments.compactMap { $0.toDomain() }
        )
    }
}

private extension String {
    func toCommentGenerationStatus() -> CommentGenerationStatus {
        switch self {
        case "DONE": return .done
        case "LIMIT_EXCEEDED": return .limitExceeded
        default: return .failed
        }
    }
}
