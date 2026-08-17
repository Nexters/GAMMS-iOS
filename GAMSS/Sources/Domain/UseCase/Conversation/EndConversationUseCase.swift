//
//  EndConversationUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 8/15/26.
//

struct EndConversationUseCase {
    private let conversationRepository: ConversationRepository

    init(conversationRepository: ConversationRepository) {
        self.conversationRepository = conversationRepository
    }

    func execute(conversationId: Int) async throws {
        try await conversationRepository.endConversation(conversationId: conversationId)
    }
}
