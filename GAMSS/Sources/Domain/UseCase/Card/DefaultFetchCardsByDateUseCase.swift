//
//  DefaultFetchCardsByDateUseCase.swift
//  GAMSS
//
//  Created by 이건준 on 8/18/26.
//

import Foundation

final class DefaultFetchCardsByDateUseCase: FetchCardsByDateUseCase {
    private let cardRepository: CardRepository
    private let emotion: Emotion
    
    init(cardRepository: CardRepository, emotion: Emotion) {
        self.cardRepository = cardRepository
        self.emotion = emotion
    }
    
    func execute(yearMonth: Date) async throws -> [DailyEmotion] {
        return try await cardRepository.fetchCardsByDate(yearMonth: yearMonth, emotion: emotion)
    }
}
