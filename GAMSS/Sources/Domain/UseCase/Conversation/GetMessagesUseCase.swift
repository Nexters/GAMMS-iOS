//
//  GetMessagesUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

struct GetMessagesUseCase {
    private let conversationRepository: ConversationRepository

    init(conversationRepository: ConversationRepository) {
        self.conversationRepository = conversationRepository
    }

    func execute(conversationId: Int) async throws -> [Message] {
        try await conversationRepository.getMessages(conversationId: conversationId)
    }
}
