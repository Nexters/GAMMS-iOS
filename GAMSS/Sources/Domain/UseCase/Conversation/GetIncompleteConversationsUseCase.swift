//
//  GetIncompleteConversationsUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

struct GetIncompleteConversationsUseCase {
    private let conversationRepository: ConversationRepository

    init(conversationRepository: ConversationRepository) {
        self.conversationRepository = conversationRepository
    }

    func execute() async throws -> [ConversationSummary] {
        try await conversationRepository.getIncompleteConversations()
    }
}
