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
        let request = CreateMessageRequestDTO(
            conversationId: conversationId,
            content: content,
            repliesToMessageId: repliesToMessageId,
            currentConversationSummary: contextSummary,
            excludeCharacters: []
        )
        let response = try await networkManager.request(
            ChatEndpoint.createMessage(request),
            responseType: APIResponse<SaveMessageResponseDTO>.self
        )
        return response.data.toDomain()
    }

    func getMessages(conversationId: Int) async throws -> [Message] {
        let response = try await networkManager.request(
            ChatEndpoint.fetchMessages(chatId: String(conversationId)),
            responseType: APIResponse<[ConversationMessageDTO]>.self
        )
        return response.data.compactMap { $0.toDomain() }
    }

    func getIncompleteConversations() async throws -> [ConversationSummary] {
        let response = try await networkManager.request(
            ChatEndpoint.fetchIncompleteChats,
            responseType: APIResponse<[ConversationSummaryDTO]>.self
        )
        return response.data.compactMap { $0.toDomain() }
    }

    func updateTitle(conversationId: Int, title: String) async throws {
        _ = try await networkManager.request(
            ChatEndpoint.updateTitle(chatId: String(conversationId), UpdateChatTitleRequestDTO(title: title)),
            responseType: APIResponse<EmptyResponseDTO>.self
        )
    }
}
