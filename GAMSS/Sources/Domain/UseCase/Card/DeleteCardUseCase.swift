//
//  DeleteCardUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 8/17/26.
//

struct DeleteCardUseCase {
    private let cardRepository: CardRepository

    init(cardRepository: CardRepository) {
        self.cardRepository = cardRepository
    }

    func execute(cardId: Int) async throws {
        try await cardRepository.deleteCard(cardId: cardId)
    }
}
