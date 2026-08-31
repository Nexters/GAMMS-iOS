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
    
    func execute(_ text: String, page: Int, size: Int) async throws -> ConversationPage {
        guard text.count >= 2 else {
            throw ConversationError.invalidSearchKeyword
        }
        
        return try await conversationRepository.searchConversations(
            text,
            page: page,
            size: size
        )
    }
}
