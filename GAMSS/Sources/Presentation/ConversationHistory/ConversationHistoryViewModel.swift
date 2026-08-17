//
//  ConversationHistoryViewModel.swift
//  GAMSS
//
//  Created by cchanmi on 8/17/26.
//

import Combine
import Foundation

@MainActor
final class ConversationHistoryViewModel: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published private(set) var isLoading = false
    @Published var alertMessage: String?

    private let getMessagesUseCase: GetMessagesUseCase
    private var loadedConversationId: Int?

    init(getMessagesUseCase: GetMessagesUseCase) {
        self.getMessagesUseCase = getMessagesUseCase
    }

    /// 같은 대화를 이미 불러온 적 있으면 재조회하지 않는다 — 카드 ↔ 대화 모드를 여러 번
    /// 오가도 네트워크 요청은 한 번만 나간다.
    func loadMessagesIfNeeded(conversationId: Int) async {
        guard loadedConversationId != conversationId else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            messages = try await getMessagesUseCase.execute(conversationId: conversationId)
            loadedConversationId = conversationId
        } catch {
            alertMessage = "대화를 불러오지 못했어요"
        }
    }

    /// 실패 알럿의 "다시 시도"에서만 호출한다 — 캐시를 지우고 다시 조회한다.
    func retryLoad(conversationId: Int) async {
        loadedConversationId = nil
        await loadMessagesIfNeeded(conversationId: conversationId)
    }

    func quotedMessage(for message: Message) -> Message? {
        guard let repliesToMessageId = message.repliesToMessageId else { return nil }
        return messages.first { $0.id == repliesToMessageId }
    }
}
