//
//  ConversationListViewModel.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

import Combine
import Foundation

@MainActor
final class ConversationListViewModel: ObservableObject {
    @Published private(set) var conversations: [ConversationSummary] = []
    @Published private(set) var isLoading = false
    @Published var alertMessage: String?

    private let getIncompleteConversationsUseCase: GetIncompleteConversationsUseCase

    init(getIncompleteConversationsUseCase: GetIncompleteConversationsUseCase) {
        self.getIncompleteConversationsUseCase = getIncompleteConversationsUseCase
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            conversations = try await getIncompleteConversationsUseCase.execute()
        } catch {
            alertMessage = "채팅방 목록을 불러오지 못했어요"
        }
    }
}
