//
//  DefaultFetchMonthlyCardsUseCase.swift
//  GAMSS
//
//  Created by 이건준 on 8/18/26.
//

import Foundation

final class DefaultFetchMonthlyCardsUseCase: FetchMonthlyCardsUseCase {
    private let cardRepository: CardRepository
    
    init(cardRepository: CardRepository) {
        self.cardRepository = cardRepository
    }
    
    func execute(yearMonth: Date) async throws -> [DailyEmotion] {
//        let responses = try await cardRepository.fetchMonthlyCards(yearMonth: yearMonth)
//        
//        return responses.map { response in
//            return DailyEmotion(
//                date: response.date,
//                emotions: response.emotions
//            )
//        }
        return [DailyEmotion(date: Date.now, emotions: []), DailyEmotion(date: Date.now, emotions: []), DailyEmotion(date: Date.now, emotions: []), DailyEmotion(date: Date.now, emotions: []), DailyEmotion(date: Date.now, emotions: []), DailyEmotion(date: Date.now, emotions: []), DailyEmotion(date: Date.now, emotions: []), DailyEmotion(date: Date.now, emotions: [])]
    }
}
