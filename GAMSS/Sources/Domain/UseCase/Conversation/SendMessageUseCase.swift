//
//  SendMessageUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import Foundation

struct SendMessageUseCase {
    private let conversationRepository: ConversationRepository

    init(conversationRepository: ConversationRepository) {
        self.conversationRepository = conversationRepository
    }

    func execute(conversationId: Int?, content: String, repliesToMessageId: Int?, contextSummary: String?, excludedCharacters: Set<EmotionCharacter>) async throws -> SentMessage {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw SendMessageValidationError.empty
        }
        guard trimmed.count <= ConversationSummaryPolicy.maxMessageLength else {
            throw SendMessageValidationError.tooLong
        }

        return try await conversationRepository.sendMessage(
            conversationId: conversationId,
            content: content,
            repliesToMessageId: repliesToMessageId,
            contextSummary: contextSummary,
            excludedCharacters: excludedCharacters
        )
    }
}
