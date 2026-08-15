//
//  DefaultDeleteConversationsUseCase.swift
//  GAMSS
//
//  Created by 이건준 on 8/15/26.
//

import Foundation

protocol DeleteConversationsUseCase {
    func execute(conversationIDs: [Int]) async throws
}

struct DefaultDeleteConversationsUseCase: DeleteConversationsUseCase {
    private let conversationRepository: ConversationRepository
    
    init(conversationRepository: ConversationRepository) {
        self.conversationRepository = conversationRepository
    }
    
    func execute(conversationIDs: [Int]) async throws {
        try await conversationRepository.deleteConversations(conversationIDs)
    }
}
