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
    @Published private(set) var selectedEmotions: Set<EmotionCharacter> = Set(EmotionCharacter.allCases)
    @Published var isEmotionPickerOpen = false

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

    /// 감정 선택을 토글한다. 최소 1개는 항상 선택되어 있어야 하므로, 마지막 1개를
    /// 해제하려는 시도는 무시한다.
    func toggleEmotion(_ emotion: EmotionCharacter) {
        if selectedEmotions.contains(emotion) {
            guard selectedEmotions.count > 1 else { return }
            selectedEmotions.remove(emotion)
        } else {
            selectedEmotions.insert(emotion)
        }
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
