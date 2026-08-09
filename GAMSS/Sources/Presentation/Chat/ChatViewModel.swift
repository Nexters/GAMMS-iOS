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
    /// 테스트에서 백그라운드 요약 저장이 끝나는 시점을 결정적으로 기다리기 위한 핸들.
    private(set) var pendingSummaryUpdateTask: Task<Void, Never>?

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
            input = ""
            seed(with: sent)

            // 요약기(온디바이스 추론)가 끝날 때까지 다음 입력을 막지 않도록 백그라운드로 돌린다.
            // self가 아니라 summaryStore를 직접 캡처해 화면을 나가도 저장은 끝까지 완료되게 한다.
            let summaryStore = summaryStore
            pendingSummaryUpdateTask = Task { await summaryStore.add(trimmed) }
        } catch {
            toastMessage = "메시지를 보내지 못했어요"
        }
    }

    /// 다른 화면(홈)에서 이미 받아온 응답으로 화면을 채운다 — 방금 받은 응답을 다시
    /// getMessages로 조회하지 않기 위한 용도.
    func seed(with sent: SentMessage) {
        conversationId = sent.message.conversationId

        // 첫 댓글은 즉시, 나머지는 순차 노출 큐로.
        messages.append(sent.message)
        if let first = sent.comments.first {
            messages.append(first)
        }
        pendingComments = Array(sent.comments.dropFirst())
        revealRemainingComments()

        if sent.commentStatus != .done {
            toastMessage = sent.commentStatus.toUserMessage()
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
                // 취소 시 flushPendingComments()가 그대로 쓸어담을 수 있도록, 자는 동안은
                // pendingComments에서 빼지 않고 들여다보기만 한다(제거는 취소 검사 통과 후에만).
                let hasNext: Bool = await MainActor.run { !self.pendingComments.isEmpty }
                guard hasNext else { break }
                try? await Task.sleep(nanoseconds: UInt64(CommentRevealPolicy.nextGapSeconds() * 1_000_000_000))
                guard !Task.isCancelled else { break }
                await MainActor.run {
                    guard !self.pendingComments.isEmpty else { return }
                    self.messages.append(self.pendingComments.removeFirst())
                }
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
