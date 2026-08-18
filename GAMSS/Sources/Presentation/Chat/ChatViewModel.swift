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
    @Published var alertMessage: String?
    @Published private(set) var pendingUserMessage: PendingUserMessage?
    @Published private(set) var replyTarget: Message?
    @Published var isEndConfirmationPresented = false
    @Published private(set) var isEnding = false
    @Published private(set) var isConversationEnded = false
    @Published private(set) var createdCard: Card?
    @Published private(set) var isWaitingForReply = false
    @Published private(set) var tokenUsage: TokenUsage?
    @Published private(set) var isLoadingTokenUsage = false
    @Published var tokenUsageErrorMessage: String?
    @Published var isTokenUsagePopoverPresented = false
    @Published private(set) var isTokenExceeded = false

    private var conversationId: Int?
    private let initialSentMessage: SentMessage?
    private let sendMessageUseCase: SendMessageUseCase
    private let getMessagesUseCase: GetMessagesUseCase
    private let endConversationUseCase: EndConversationUseCase
    private let createCardUseCase: CreateCardUseCase
    private let getTokenUsageUseCase: GetTokenUsageUseCase
    private let summaryStore: ConversationSummaryStore
    /// 테스트에서 순차 노출이 끝나는 시점을 결정적으로 기다리기 위한 핸들.
    private(set) var revealTask: Task<Void, Never>?
    private var isTokenUsageStale = true
    /// 테스트에서 백그라운드 요약 저장이 끝나는 시점을 결정적으로 기다리기 위한 핸들.
    private(set) var pendingSummaryUpdateTask: Task<Void, Never>?

    init(
        sendMessageUseCase: SendMessageUseCase,
        getMessagesUseCase: GetMessagesUseCase,
        endConversationUseCase: EndConversationUseCase,
        createCardUseCase: CreateCardUseCase,
        getTokenUsageUseCase: GetTokenUsageUseCase,
        summaryStore: ConversationSummaryStore,
        conversationId: Int? = nil,
        initialSentMessage: SentMessage? = nil
    ) {
        self.sendMessageUseCase = sendMessageUseCase
        self.getMessagesUseCase = getMessagesUseCase
        self.endConversationUseCase = endConversationUseCase
        self.createCardUseCase = createCardUseCase
        self.getTokenUsageUseCase = getTokenUsageUseCase
        self.summaryStore = summaryStore
        self.conversationId = conversationId
        self.initialSentMessage = initialSentMessage
    }

    /// 화면 진입 시 한 번 호출한다. 다른 화면에서 이미 받아온 응답이 있으면 그걸로 채우고,
    /// 없으면 기존 대화의 히스토리를 불러온다.
    func start() async {
        async let tokenUsageFetch: Void = loadTokenUsage()

        if let initialSentMessage {
            seed(with: initialSentMessage)
        } else if let conversationId {
            await load(conversationId: conversationId)
        }

        await tokenUsageFetch
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
            alertMessage = "대화를 불러오지 못했어요"
        }
    }

    /// 입력창의 원시 입력값을 받아 정책에 맞게 정규화하고, 키보드를 내려야 하는지 돌려준다.
    func updateInput(_ rawValue: String) -> Bool {
        let result = ConversationSummaryPolicy.normalizeInput(rawValue)
        input = result.value
        return result.shouldDismissKeyboard
    }

    var isSendDisabled: Bool {
        input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending || isConversationEnded || isTokenExceeded
    }

    /// 아직 대화방이 만들어지지 않았거나(첫 메시지 전) 이미 종료된 대화는 다시 종료할 수 없다.
    var canEndConversation: Bool {
        conversationId != nil && !isConversationEnded
    }

    var isCardCreationFailureAlert: Bool {
        isConversationEnded && createdCard == nil && alertMessage != nil
    }

    var composerDisabledPlaceholder: String {
        isConversationEnded ? "대화가 종료됐어요" : "오늘의 토큰을 모두 사용했어요"
    }

    func loadTokenUsage() async {
        guard isTokenUsageStale else { return }

        isLoadingTokenUsage = true
        tokenUsageErrorMessage = nil
        defer { isLoadingTokenUsage = false }
        do {
            let usage = try await getTokenUsageUseCase.execute()
            tokenUsage = usage
            isTokenExceeded = usage.exceeded
            isTokenUsageStale = false
        } catch {
            tokenUsageErrorMessage = "토큰 사용량을 불러오지 못했어요"
        }
    }

    func send() async {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }

        flushPendingComments()
        isSending = true
        isWaitingForReply = true
        defer { isSending = false }

        let replyTarget = replyTarget
        pendingUserMessage = PendingUserMessage(
            content: trimmed,
            sentAt: Date(),
            quotedSenderLabel: replyTarget.flatMap { QuotedReplyHeader.label(forQuotedSender: $0.sender) },
            quotedContent: replyTarget?.content
        )
        input = ""

        let contextSummary = await summaryStore.current()

        do {
            let sent = try await sendMessageUseCase.execute(
                conversationId: conversationId,
                content: trimmed,
                repliesToMessageId: replyTarget?.id,
                contextSummary: contextSummary,
                excludedCharacters: []
            )
            pendingUserMessage = nil
            if self.replyTarget == replyTarget {
                self.replyTarget = nil
            }
            seed(with: sent)

            // 요약기(온디바이스 추론)가 끝날 때까지 다음 입력을 막지 않도록 백그라운드로 돌린다.
            // self가 아니라 summaryStore를 직접 캡처해 화면을 나가도 저장은 끝까지 완료되게 한다.
            let summaryStore = summaryStore
            pendingSummaryUpdateTask = Task { await summaryStore.add(trimmed) }
        } catch let error as SendMessageValidationError {
            pendingUserMessage = nil
            isWaitingForReply = false
            if input.isEmpty { input = trimmed }
            alertMessage = error.errorDescription
        } catch {
            pendingUserMessage = nil
            isWaitingForReply = false
            if input.isEmpty { input = trimmed }
            alertMessage = "메시지를 보내지 못했어요"
        }
    }

    /// 다른 화면(홈)에서 이미 받아온 응답으로 화면을 채운다 — 방금 받은 응답을 다시
    /// getMessages로 조회하지 않기 위한 용도.
    func seed(with sent: SentMessage) {
        conversationId = sent.message.conversationId
        isTokenUsageStale = true

        // 첫 댓글은 즉시, 나머지는 순차 노출 큐로.
        messages.append(sent.message)
        if let first = sent.comments.first {
            messages.append(first)
        }
        pendingComments = Array(sent.comments.dropFirst())
        // 남은 댓글이 없으면(0~1개 응답) 여기서 바로 대기 표시를 끈다.
        isWaitingForReply = !pendingComments.isEmpty
        revealRemainingComments()

        if sent.commentStatus != .done {
            alertMessage = sent.commentStatus.toUserMessage()
        }
        if sent.commentStatus == .limitExceeded {
            isTokenExceeded = true
        }
    }

    /// 답장 말풍선에 인용할 원본 메시지를 찾는다. 서버는 repliesToMessageId만 내려주므로
    /// 이미 로드된 messages에서 직접 찾아야 한다.
    func quotedMessage(for message: Message) -> Message? {
        guard let repliesToMessageId = message.repliesToMessageId else { return nil }
        return messages.first { $0.id == repliesToMessageId }
    }

    /// 캐릭터 말풍선을 길게 눌렀을 때 호출한다. 사용자 메시지는 답장 대상이 될 수 없으므로
    /// 무시한다 — View는 아무 버블에나 제스처를 붙이고, 이 판단은 여기서만 한다.
    @discardableResult
    func startReply(to message: Message) -> Bool {
        guard case .character = message.sender else { return false }
        replyTarget = message
        return true
    }

    func cancelReply() {
        replyTarget = nil
    }

    /// 헤더의 종료 버튼이 누르는 진입점. 확인 팝업만 띄우고 실제 종료는 confirmEndConversation()에서.
    func requestEndConversation() {
        guard canEndConversation else { return }
        isEndConfirmationPresented = true
    }

    /// 종료 확인 팝업에서 "종료할래요"를 눌렀을 때. endConversation → createCard 순서로 호출한다.
    /// endConversation이 성공하면 서버에서는 이미 대화가 끝난 상태이므로, 뒤이은 createCard가
    /// 실패해도 입력창은 다시 열어주지 않는다 — retryCreateCard()로만 재시도한다.
    func confirmEndConversation() async {
        guard let conversationId, !isEnding else { return }
        isEnding = true
        defer { isEnding = false }

        do {
            try await endConversationUseCase.execute(conversationId: conversationId)
        } catch {
            alertMessage = "대화를 종료하지 못했어요"
            return
        }

        isConversationEnded = true
        await createCard(conversationId: conversationId)
    }

    /// createCard만 다시 시도한다. endConversation은 이미 성공했으므로 재호출하지 않는다.
    func retryCreateCard() async {
        guard let conversationId, isConversationEnded, !isEnding else { return }
        isEnding = true
        defer { isEnding = false }
        await createCard(conversationId: conversationId)
    }

    func dismissCard() {
        createdCard = nil
    }

    /// summary는 채팅 압축본(ConversationSummaryStore)을 그대로 재사용한다 — 카드 전용 요약을
    /// 따로 만들지 않는다. emotion은 지금까지 등장한 캐릭터 답장의 최빈값.
    private func createCard(conversationId: Int) async {
        let summary = await summaryStore.current() ?? ""
        let emotion = EmotionCharacter.dominant(in: messages)
        do {
            createdCard = try await createCardUseCase.execute(conversationId: conversationId, emotion: emotion, summary: summary)
        } catch {
            alertMessage = "카드를 만들지 못했어요. 다시 시도해주세요"
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
                    if self.pendingComments.isEmpty {
                        self.isWaitingForReply = false
                    }
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
