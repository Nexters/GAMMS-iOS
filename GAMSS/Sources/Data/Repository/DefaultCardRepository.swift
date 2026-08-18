//
//  DefaultCardRepository.swift
//  GAMSS
//
//  Created by cchanmi on 8/15/26.
//

import Foundation

final class DefaultCardRepository: CardRepository {
    private let networkManager: NetworkRequesting
    
    init(networkManager: NetworkRequesting) {
        self.networkManager = networkManager
    }
    
    func createCard(conversationId: Int, emotion: EmotionCharacter?, summary: String) async throws -> Card {
        let request = CreateCardRequestDTO(
            conversationId: conversationId,
            emotion: emotion.map { EmotionCharacterServerKeyMapping.serverKey(for: $0) },
            summary: summary
        )
        let response = try await networkManager.request(
            CardEndpoint.createCard(request),
            responseType: APIResponse<CardResponseDTO>.self
        )
        return response.data.toDomain()
    }
    
    func getCard(cardId: Int) async throws -> Card {
        let response = try await networkManager.request(
            CardEndpoint.fetchCard(cardId: String(cardId)),
            responseType: APIResponse<CardResponseDTO>.self
        )
        return response.data.toDomain()
    }
    
    func deleteCard(cardId: Int) async throws {
        _ = try await networkManager.request(
            CardEndpoint.deleteCard(cardId: String(cardId)),
            responseType: APIResponse<EmptyResponseDTO>.self
        )
    }
    
    func fetchMonthlyCards(yearMonth: Date) async throws -> [DailyEmotion] {
        let yearMonth = DateFormatterFactory.dateWithDot.string(from: yearMonth)
        let response = try await networkManager.request(
            CardEndpoint.fetchMonthlyCards(yearMonth: yearMonth),
            responseType: APIResponse<[FetchMonthlyCardsResponseDTO]>.self
        )
        return response.data.compactMap { response in
            guard let date = DateFormatterFactory.dateWithDot.date(from: response.date) else {
                return nil
            }
            
            return DailyEmotion(
                date: date,
                emotions: []
            )
        }
    }
}
