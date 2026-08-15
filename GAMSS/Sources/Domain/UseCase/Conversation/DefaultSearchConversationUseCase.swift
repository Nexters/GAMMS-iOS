//
//  DefaultSearchConversationUseCase.swift
//  GAMSS
//
//  Created by 이건준 on 8/15/26.
//

import Foundation

struct DefaultSearchConversationUseCase: SearchConversationUseCase {
    private let conversationRepository: ConversationRepository
    
    init(conversationRepository: ConversationRepository) {
        self.conversationRepository = conversationRepository
    }
    
    func execute(_ text: String) async throws -> [ConversationSummary] {
        guard text.count >= 2 else {
            throw ConversationError.invalidSearchKeyword
        }
        
        let data = try await conversationRepository.searchConversations(text)
        return data.content.map { ConversationSummary(
            id: $0.conversationId,
            title: $0.title,
            createdAt: Date()
        ) }
    }
}
