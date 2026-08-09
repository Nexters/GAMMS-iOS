//
//  HomeViewModel.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var input: String = ""
    @Published private(set) var isSending = false
    @Published var toastMessage: String?
    @Published var createdConversationId: Int?
    @Published private(set) var createdSentMessage: SentMessage?

    private let sendMessageUseCase: SendMessageUseCase

    init(sendMessageUseCase: SendMessageUseCase) {
        self.sendMessageUseCase = sendMessageUseCase
    }

    func send() async {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }

        isSending = true
        defer { isSending = false }

        do {
            let sent = try await sendMessageUseCase.execute(
                conversationId: nil,
                content: trimmed,
                repliesToMessageId: nil,
                contextSummary: nil
            )
            input = ""
            createdSentMessage = sent
            createdConversationId = sent.message.conversationId
        } catch {
            toastMessage = "쪽지를 보내지 못했어요"
        }
    }
}
