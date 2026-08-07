//
//  SendMessageUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

struct SendMessageUseCase {
    private let conversationRepository: ConversationRepository

    init(conversationRepository: ConversationRepository) {
        self.conversationRepository = conversationRepository
    }

    func execute(conversationId: Int?, content: String, repliesToMessageId: Int?, contextSummary: String?) async throws -> SentMessage {
        try await conversationRepository.sendMessage(
            conversationId: conversationId,
            content: content,
            repliesToMessageId: repliesToMessageId,
            contextSummary: contextSummary
        )
    }
}
