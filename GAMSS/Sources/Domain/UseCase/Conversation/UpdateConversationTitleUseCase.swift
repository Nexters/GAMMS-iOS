//
//  UpdateConversationTitleUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 8/14/26.
//

import Foundation

struct UpdateConversationTitleUseCase {
    private let conversationRepository: ConversationRepository

    init(conversationRepository: ConversationRepository) {
        self.conversationRepository = conversationRepository
    }

    func execute(conversationId: Int, title: String) async throws {
        try await conversationRepository.updateTitle(conversationId: conversationId, title: title)
    }
}
