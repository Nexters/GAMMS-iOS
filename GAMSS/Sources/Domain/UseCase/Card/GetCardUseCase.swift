//
//  GetCardUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 8/17/26.
//

struct GetCardUseCase {
    private let cardRepository: CardRepository

    init(cardRepository: CardRepository) {
        self.cardRepository = cardRepository
    }

    func execute(cardId: Int) async throws -> Card {
        try await cardRepository.getCard(cardId: cardId)
    }
}
