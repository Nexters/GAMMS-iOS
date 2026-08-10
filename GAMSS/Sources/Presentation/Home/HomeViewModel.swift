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
    @Published var alertMessage: String?
    @Published var createdConversationId: Int?
    @Published private(set) var createdSentMessage: SentMessage?

    private let sendMessageUseCase: SendMessageUseCase

    init(sendMessageUseCase: SendMessageUseCase) {
        self.sendMessageUseCase = sendMessageUseCase
    }

    /// 입력창의 원시 입력값을 받아 정책에 맞게 정규화하고, 키보드를 내려야 하는지 돌려준다.
    func updateInput(_ rawValue: String) -> Bool {
        let result = ConversationSummaryPolicy.normalizeInput(rawValue)
        input = result.value
        return result.shouldDismissKeyboard
    }

    var isSendDisabled: Bool {
        input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending
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
        } catch let error as SendMessageValidationError {
            alertMessage = error.errorDescription
        } catch {
            alertMessage = "쪽지를 보내지 못했어요"
        }
    }
}
