//
//  CreateCardUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 8/15/26.
//

struct CreateCardUseCase {
    private let cardRepository: CardRepository

    init(cardRepository: CardRepository) {
        self.cardRepository = cardRepository
    }

    func execute(conversationId: Int, emotion: EmotionCharacter?, summary: String) async throws -> Card {
        try await cardRepository.createCard(conversationId: conversationId, emotion: emotion, summary: summary)
    }
}
