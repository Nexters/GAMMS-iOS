//
//  DefaultConversationRepository.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

final class DefaultConversationRepository: ConversationRepository {
    private let networkManager: NetworkRequesting

    init(networkManager: NetworkRequesting) {
        self.networkManager = networkManager
    }

    func sendMessage(conversationId: Int?, content: String, repliesToMessageId: Int?, contextSummary: String?) async throws -> SentMessage {
        let request = SaveMessageRequestDTO(
            content: content,
            conversationId: conversationId,
            repliesToMessageId: repliesToMessageId,
            currentConversationSummary: contextSummary
        )
        let response = try await networkManager.request(
            ConversationEndpoint.saveMessage(request),
            responseType: APIResponse<SaveMessageResponseDTO>.self
        )
        return response.data.toDomain()
    }

    func getMessages(conversationId: Int) async throws -> [Message] {
        let response = try await networkManager.request(
            ConversationEndpoint.getMessages(conversationId: conversationId),
            responseType: APIResponse<[ConversationMessageDTO]>.self
        )
        return response.data.compactMap { $0.toDomain() }
    }
}
