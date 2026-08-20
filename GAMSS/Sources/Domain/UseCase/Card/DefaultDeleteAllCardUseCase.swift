//
//  DefaultDeleteAllCardUseCase.swift
//  GAMSS
//
//  Created by 이건준 on 8/20/26.
//

import Foundation

struct DefaultDeleteAllCardUseCase: DeleteAllCardUseCase {
    private let cardRepository: CardRepository
    
    init(cardRepository: CardRepository) {
        self.cardRepository = cardRepository
    }
    
    func execute() async throws {
        try await cardRepository.deleteAllCard()
    }
}
