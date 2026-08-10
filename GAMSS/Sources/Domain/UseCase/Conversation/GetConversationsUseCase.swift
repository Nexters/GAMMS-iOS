//
//  GetConversationsUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

struct GetConversationsUseCase {
    private let conversationRepository: ConversationRepository

    init(conversationRepository: ConversationRepository) {
        self.conversationRepository = conversationRepository
    }

    func execute(date: String) async throws -> [ConversationSummary] {
        try await conversationRepository.getConversations(date: date)
    }
}
