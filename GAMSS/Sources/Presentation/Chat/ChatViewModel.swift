//
//  ChatViewModel.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import Combine
import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published private(set) var pendingComments: [Message] = []
    @Published var input: String = ""
    @Published private(set) var isSending = false
    @Published var toastMessage: String?

    private var conversationId: Int?
    private let sendMessageUseCase: SendMessageUseCase
    private let getMessagesUseCase: GetMessagesUseCase
    private let summaryStore: ConversationSummaryStore
    private var revealTask: Task<Void, Never>?

    init(sendMessageUseCase: SendMessageUseCase, getMessagesUseCase: GetMessagesUseCase, summaryStore: ConversationSummaryStore) {
        self.sendMessageUseCase = sendMessageUseCase
        self.getMessagesUseCase = getMessagesUseCase
        self.summaryStore = summaryStore
    }

    /// 재진입 시 히스토리를 불러온다. 순차 노출은 적용하지 않고 한 번에 표시한다.
    func load(conversationId: Int) async {
        self.conversationId = conversationId
        do {
            let history = try await getMessagesUseCase.execute(conversationId: conversationId)
            messages = history
            let userUtterances = history.compactMap { message -> String? in
                guard message.sender == .user else { return nil }
                return message.content
            }
            await summaryStore.restore(historicalUtterances: userUtterances)
        } catch {
            toastMessage = "대화를 불러오지 못했어요"
        }
    }

    func send() async {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }

        flushPendingComments()
        isSending = true
        defer { isSending = false }

        let contextSummary = await summaryStore.current()

        do {
            let sent = try await sendMessageUseCase.execute(
                conversationId: conversationId,
                content: trimmed,
                repliesToMessageId: nil,
                contextSummary: contextSummary
            )
            conversationId = sent.message.conversationId
            input = ""

            // 먼저 화면에 반영 — 첫 댓글은 즉시, 나머지는 순차 노출 큐로.
            messages.append(sent.message)
            if let first = sent.comments.first {
                messages.append(first)
            }
            pendingComments = Array(sent.comments.dropFirst())
            revealRemainingComments()

            if sent.commentStatus != .done {
                toastMessage = sent.commentStatus.toUserMessage()
            }

            // 요약기가 돌 수 있어 화면 갱신 뒤에, 블로킹 없이 둔다.
            await summaryStore.add(trimmed)
        } catch {
            toastMessage = "메시지를 보내지 못했어요"
        }
    }

    private func flushPendingComments() {
        revealTask?.cancel()
        revealTask = nil
        guard !pendingComments.isEmpty else { return }
        messages.append(contentsOf: pendingComments)
        pendingComments.removeAll()
    }

    private func revealRemainingComments() {
        guard !pendingComments.isEmpty else { return }
        revealTask = Task { [weak self] in
            guard let self else { return }
            while true {
                let next: Message? = await MainActor.run {
                    guard !self.pendingComments.isEmpty else { return nil }
                    return self.pendingComments.removeFirst()
                }
                guard let next else { break }
                try? await Task.sleep(nanoseconds: UInt64(CommentRevealPolicy.nextGapSeconds() * 1_000_000_000))
                guard !Task.isCancelled else { break }
                await MainActor.run { self.messages.append(next) }
            }
        }
    }
}

private extension CommentGenerationStatus {
    func toUserMessage() -> String? {
        switch self {
        case .done: nil
        case .failed: "답장을 받지 못했어요. 잠시 후 다시 보내볼까요?"
        case .limitExceeded: "오늘은 대화를 많이 했어요. 내일 다시 이야기해요."
        }
    }
}
