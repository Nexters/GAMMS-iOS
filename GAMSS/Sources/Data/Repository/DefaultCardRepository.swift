//
//  DefaultCardRepository.swift
//  GAMSS
//
//  Created by cchanmi on 8/15/26.
//

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
}
