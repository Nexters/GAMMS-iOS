//
//  ChatViewModelTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import XCTest
@testable import GAMSS

/// 테스트에서 send()가 네트워크 응답을 받기 전 상태(펜딩 사용자 메시지, 입력창 비움 등)를
/// 검증할 수 있도록, sendMessage 반환을 원하는 시점까지 붙잡아두는 게이트.
private actor SendGate {
    private var isOpen = false
    private var continuation: CheckedContinuation<Void, Never>?

    func wait() async {
        if isOpen { return }
        await withCheckedContinuation { continuation = $0 }
    }

    func open() {
        isOpen = true
        continuation?.resume()
        continuation = nil
    }
}

private final class MockConversationRepository: ConversationRepository {
    var stubbedSendResult: Result<SentMessage, Error> = .failure(SummaryError.inferenceFailed())
    var stubbedMessages: [Message] = []
    var sendGate: SendGate?
    var stubbedEndConversationResult: Result<Void, Error> = .success(())
    private(set) var sendCallCount = 0
    private(set) var getMessagesCallCount = 0
    private(set) var endConversationCallCount = 0
    private(set) var receivedContextSummary: String?
    private(set) var receivedExcludedCharacters: Set<EmotionCharacter>?
    private(set) var receivedRepliesToMessageId: Int?
    private(set) var receivedEndConversationId: Int?

    func sendMessage(conversationId: Int?, content: String, repliesToMessageId: Int?, contextSummary: String?, excludedCharacters: Set<EmotionCharacter>) async throws -> SentMessage {
        sendCallCount += 1
        receivedContextSummary = contextSummary
        receivedExcludedCharacters = excludedCharacters
        receivedRepliesToMessageId = repliesToMessageId
        await sendGate?.wait()
        return try stubbedSendResult.get()
    }

    func getMessages(conversationId: Int) async throws -> [Message] {
        getMessagesCallCount += 1
        return stubbedMessages
    }

    func getIncompleteConversations() async throws -> [ConversationSummary] {
        []
    }

    func updateTitle(conversationId: Int, title: String) async throws {
        fatalError("not used in this test")
    }

    func endConversation(conversationId: Int) async throws {
        endConversationCallCount += 1
        receivedEndConversationId = conversationId
        _ = try stubbedEndConversationResult.get()
    }

    func deleteConversations(_ ids: [Int]) async throws {
        fatalError("not used in this test")
    }

    func searchConversations(_ text: String) async throws -> SearchChatResponseDTO {
        fatalError("not used in this test")
    }
}

private final class MockCardRepository: CardRepository {
    var stubbedResult: Result<Card, Error> = .failure(SummaryError.inferenceFailed())
    private(set) var createCardCallCount = 0
    private(set) var receivedConversationId: Int?
    private(set) var receivedEmotion: EmotionCharacter?
    private(set) var receivedSummary: String?

    func createCard(conversationId: Int, emotion: EmotionCharacter?, summary: String) async throws -> Card {
        createCardCallCount += 1
        receivedConversationId = conversationId
        receivedEmotion = emotion
        receivedSummary = summary
        return try stubbedResult.get()
    }

    func getCard(cardId: Int) async throws -> Card {
        fatalError("사용 안 함")
    }

    func deleteCard(cardId: Int) async throws {
        fatalError("사용 안 함")
    }
}

private actor MockConversationSummaryStore: ConversationSummaryStore {
    private(set) var addedUtterances: [String] = []
    private(set) var restoredHistories: [[String]] = []
    nonisolated(unsafe) var stubbedCurrent: String?

    func add(_ utterance: String) async { addedUtterances.append(utterance) }
    func current() async -> String? { stubbedCurrent }
    func reset() async {}
    func restore(historicalUtterances: [String]) async { restoredHistories.append(historicalUtterances) }
}

@MainActor
final class ChatViewModelTests: XCTestCase {
    private func makeViewModel(
        repository: MockConversationRepository = MockConversationRepository(),
        cardRepository: MockCardRepository = MockCardRepository(),
        summaryStore: MockConversationSummaryStore = MockConversationSummaryStore(),
        conversationId: Int? = nil,
        initialSentMessage: SentMessage? = nil
    ) -> ChatViewModel {
        ChatViewModel(
            sendMessageUseCase: SendMessageUseCase(conversationRepository: repository),
            getMessagesUseCase: GetMessagesUseCase(conversationRepository: repository),
            endConversationUseCase: EndConversationUseCase(conversationRepository: repository),
            createCardUseCase: CreateCardUseCase(cardRepository: cardRepository),
            summaryStore: summaryStore,
            conversationId: conversationId,
            initialSentMessage: initialSentMessage
        )
    }

    func test_send_onSuccess_appendsSentMessageAndFirstCommentImmediately() async {
        let repository = MockConversationRepository()
        let sentMessage = Message(id: 1, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        let comment1 = Message(id: 2, conversationId: 10, sender: .character(.joy), content: "반가워", repliesToMessageId: 1, createdAt: Date(timeIntervalSince1970: 0))
        let comment2 = Message(id: 3, conversationId: 10, sender: .character(.joy), content: "오늘 어때?", repliesToMessageId: 1, createdAt: Date(timeIntervalSince1970: 0))
        repository.stubbedSendResult = .success(SentMessage(message: sentMessage, commentStatus: .done, comments: [comment1, comment2]))
        let viewModel = makeViewModel(repository: repository)
        viewModel.input = "안녕"

        await viewModel.send()

        XCTAssertEqual(viewModel.messages, [sentMessage, comment1])
        XCTAssertEqual(viewModel.pendingComments, [comment2])
        XCTAssertEqual(viewModel.input, "")
    }

    func test_send_onSuccess_addsContentToSummaryStoreAfterUpdatingMessages() async {
        let repository = MockConversationRepository()
        let sentMessage = Message(id: 1, conversationId: 10, sender: .user, content: "오늘 힘들었어", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        repository.stubbedSendResult = .success(SentMessage(message: sentMessage, commentStatus: .done, comments: []))
        let summaryStore = MockConversationSummaryStore()
        let viewModel = makeViewModel(repository: repository, summaryStore: summaryStore)
        viewModel.input = "오늘 힘들었어"

        await viewModel.send()
        await viewModel.pendingSummaryUpdateTask?.value

        let added = await summaryStore.addedUtterances
        XCTAssertEqual(added, ["오늘 힘들었어"], "전송 성공한 사용자 발화만 압축 저장소에 추가되어야 함")
    }

    func test_send_onFailure_doesNotAddToSummaryStore() async {
        let repository = MockConversationRepository()
        repository.stubbedSendResult = .failure(SummaryError.inferenceFailed())
        let summaryStore = MockConversationSummaryStore()
        let viewModel = makeViewModel(repository: repository, summaryStore: summaryStore)
        viewModel.input = "실패할 메시지"

        await viewModel.send()

        let added = await summaryStore.addedUtterances
        XCTAssertTrue(added.isEmpty, "전송 실패한 발화는 압축 저장소에 들어가면 안 됨")
    }

    func test_send_usesCurrentContextSummaryFromStore() async {
        let repository = MockConversationRepository()
        repository.stubbedSendResult = .success(SentMessage(
            message: Message(id: 1, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0)),
            commentStatus: .done, comments: []
        ))
        let summaryStore = MockConversationSummaryStore()
        summaryStore.stubbedCurrent = "이전 압축본"
        let viewModel = makeViewModel(repository: repository, summaryStore: summaryStore)
        viewModel.input = "안녕"

        await viewModel.send()

        XCTAssertEqual(repository.receivedContextSummary, "이전 압축본")
    }

    func test_send_commentStatusNotDone_keepsMessageAndSetsAlert() async {
        let repository = MockConversationRepository()
        let sentMessage = Message(id: 1, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        repository.stubbedSendResult = .success(SentMessage(message: sentMessage, commentStatus: .limitExceeded, comments: []))
        let viewModel = makeViewModel(repository: repository)
        viewModel.input = "안녕"

        await viewModel.send()

        XCTAssertEqual(viewModel.messages, [sentMessage], "댓글 생성 실패해도 보낸 메시지는 화면에 유지되어야 함")
        XCTAssertNotNil(viewModel.alertMessage)
    }

    func test_send_contentTooLong_setsValidationAlertAndDoesNotCallRepository() async {
        let repository = MockConversationRepository()
        let viewModel = makeViewModel(repository: repository)
        viewModel.input = String(repeating: "가", count: ConversationSummaryPolicy.maxMessageLength + 1)

        await viewModel.send()

        XCTAssertEqual(repository.sendCallCount, 0, "최종 검증에 걸리면 네트워크 호출까지 가면 안 됨")
        XCTAssertEqual(viewModel.alertMessage, SendMessageValidationError.tooLong.errorDescription)
    }

    func test_send_beforeNetworkResponds_showsPendingUserMessageAndClearsInput() async {
        let repository = MockConversationRepository()
        let gate = SendGate()
        repository.sendGate = gate
        let sentMessage = Message(id: 1, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        repository.stubbedSendResult = .success(SentMessage(message: sentMessage, commentStatus: .done, comments: []))
        let viewModel = makeViewModel(repository: repository)
        viewModel.input = "안녕"

        let sendTask = Task { await viewModel.send() }
        while viewModel.pendingUserMessage == nil {
            await Task.yield()
        }

        XCTAssertEqual(viewModel.pendingUserMessage?.content, "안녕")
        XCTAssertEqual(viewModel.input, "", "응답을 기다리지 않고 입력창이 바로 비워져야 함")
        XCTAssertTrue(viewModel.messages.isEmpty, "응답 전에는 확정 목록에 들어가면 안 됨")

        await gate.open()
        await sendTask.value

        XCTAssertNil(viewModel.pendingUserMessage)
        XCTAssertEqual(viewModel.messages, [sentMessage])
    }

    func test_send_onFailure_clearsPendingUserMessageAndRestoresInput() async {
        let repository = MockConversationRepository()
        repository.stubbedSendResult = .failure(SummaryError.inferenceFailed())
        let viewModel = makeViewModel(repository: repository)
        viewModel.input = "실패할 메시지"

        await viewModel.send()

        XCTAssertNil(viewModel.pendingUserMessage)
        XCTAssertEqual(viewModel.input, "실패할 메시지", "실패하면 작성 중이던 내용을 잃지 않도록 복원되어야 함")
        XCTAssertNotNil(viewModel.alertMessage)
    }

    func test_send_onFailure_doesNotOverwriteInputIfUserTypedSomethingNewWhileSending() async {
        let repository = MockConversationRepository()
        let gate = SendGate()
        repository.sendGate = gate
        repository.stubbedSendResult = .failure(SummaryError.inferenceFailed())
        let viewModel = makeViewModel(repository: repository)
        viewModel.input = "실패할 메시지"

        let sendTask = Task { await viewModel.send() }
        while viewModel.pendingUserMessage == nil {
            await Task.yield()
        }

        viewModel.input = "그 사이에 새로 입력한 메시지"
        await gate.open()
        await sendTask.value

        XCTAssertEqual(viewModel.input, "그 사이에 새로 입력한 메시지", "전송 실패 시점에 사용자가 이미 새 내용을 입력 중이었다면 그 내용을 덮어쓰면 안 됨")
        XCTAssertNil(viewModel.pendingUserMessage)
    }

    func test_startReply_characterMessage_setsReplyTarget() {
        let viewModel = makeViewModel()
        let characterMessage = Message(id: 5, conversationId: 10, sender: .character(.anxiety), content: "안녕하세용", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))

        viewModel.startReply(to: characterMessage)

        XCTAssertEqual(viewModel.replyTarget, characterMessage)
    }

    func test_startReply_userMessage_isIgnored() {
        let viewModel = makeViewModel()
        let userMessage = Message(id: 5, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))

        viewModel.startReply(to: userMessage)

        XCTAssertNil(viewModel.replyTarget, "사용자 메시지는 답장 대상이 될 수 없음")
    }

    func test_cancelReply_clearsReplyTarget() {
        let viewModel = makeViewModel()
        viewModel.startReply(to: Message(id: 5, conversationId: 10, sender: .character(.joy), content: "반가워", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0)))

        viewModel.cancelReply()

        XCTAssertNil(viewModel.replyTarget)
    }

    func test_startReply_secondCharacterMessage_replacesReplyTarget() {
        let viewModel = makeViewModel()
        let first = Message(id: 5, conversationId: 10, sender: .character(.joy), content: "반가워", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        let second = Message(id: 6, conversationId: 10, sender: .character(.anxiety), content: "안녕하세용", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        viewModel.startReply(to: first)

        viewModel.startReply(to: second)

        XCTAssertEqual(viewModel.replyTarget, second)
    }

    func test_send_withReplyTarget_passesRepliesToMessageIdAndClearsOnSuccess() async {
        let repository = MockConversationRepository()
        let sentMessage = Message(id: 2, conversationId: 10, sender: .user, content: "고마워", repliesToMessageId: 5, createdAt: Date(timeIntervalSince1970: 0))
        repository.stubbedSendResult = .success(SentMessage(message: sentMessage, commentStatus: .done, comments: []))
        let viewModel = makeViewModel(repository: repository)
        viewModel.startReply(to: Message(id: 5, conversationId: 10, sender: .character(.anxiety), content: "안녕하세용", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0)))
        viewModel.input = "고마워"

        await viewModel.send()

        XCTAssertEqual(repository.receivedRepliesToMessageId, 5)
        XCTAssertNil(viewModel.replyTarget, "성공하면 답장 모드가 자동으로 꺼져야 함")
    }

    func test_send_withReplyTarget_onFailure_keepsReplyTarget() async {
        let repository = MockConversationRepository()
        repository.stubbedSendResult = .failure(SummaryError.inferenceFailed())
        let viewModel = makeViewModel(repository: repository)
        let replyTarget = Message(id: 5, conversationId: 10, sender: .character(.anxiety), content: "안녕하세용", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        viewModel.startReply(to: replyTarget)
        viewModel.input = "고마워"

        await viewModel.send()

        XCTAssertEqual(viewModel.replyTarget, replyTarget, "실패하면 답장 대상을 다시 고를 필요 없이 유지되어야 함")
    }

    func test_send_withReplyTarget_pendingUserMessageShowsQuoteImmediately() async {
        let repository = MockConversationRepository()
        let gate = SendGate()
        repository.sendGate = gate
        repository.stubbedSendResult = .success(SentMessage(
            message: Message(id: 2, conversationId: 10, sender: .user, content: "고마워", repliesToMessageId: 5, createdAt: Date(timeIntervalSince1970: 0)),
            commentStatus: .done, comments: []
        ))
        let viewModel = makeViewModel(repository: repository)
        viewModel.startReply(to: Message(id: 5, conversationId: 10, sender: .character(.anxiety), content: "안녕하세용", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0)))
        viewModel.input = "고마워"

        let sendTask = Task { await viewModel.send() }
        while viewModel.pendingUserMessage == nil {
            await Task.yield()
        }

        XCTAssertEqual(viewModel.pendingUserMessage?.quotedSenderLabel, "불안에게 답장")
        XCTAssertEqual(viewModel.pendingUserMessage?.quotedContent, "안녕하세용")

        await gate.open()
        await sendTask.value
    }

    func test_send_onSuccess_doesNotClearReplyTargetIfUserStartedNewReplyMidFlight() async {
        let repository = MockConversationRepository()
        let gate = SendGate()
        repository.sendGate = gate
        repository.stubbedSendResult = .success(SentMessage(
            message: Message(id: 2, conversationId: 10, sender: .user, content: "고마워", repliesToMessageId: 5, createdAt: Date(timeIntervalSince1970: 0)),
            commentStatus: .done, comments: []
        ))
        let viewModel = makeViewModel(repository: repository)
        viewModel.startReply(to: Message(id: 5, conversationId: 10, sender: .character(.anxiety), content: "안녕하세용", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0)))
        viewModel.input = "고마워"

        let sendTask = Task { await viewModel.send() }
        while viewModel.pendingUserMessage == nil {
            await Task.yield()
        }

        let newTarget = Message(id: 6, conversationId: 10, sender: .character(.joy), content: "반가워", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        viewModel.startReply(to: newTarget)

        await gate.open()
        await sendTask.value

        XCTAssertEqual(viewModel.replyTarget, newTarget, "전송 성공 처리가 그 사이에 새로 고른 답장 대상을 지우면 안 됨")
    }

    func test_send_withoutReplyTarget_pendingUserMessageHasNoQuote() async {
        let repository = MockConversationRepository()
        let gate = SendGate()
        repository.sendGate = gate
        repository.stubbedSendResult = .success(SentMessage(
            message: Message(id: 1, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0)),
            commentStatus: .done, comments: []
        ))
        let viewModel = makeViewModel(repository: repository)
        viewModel.input = "안녕"

        let sendTask = Task { await viewModel.send() }
        while viewModel.pendingUserMessage == nil {
            await Task.yield()
        }

        XCTAssertNil(viewModel.pendingUserMessage?.quotedSenderLabel)
        XCTAssertNil(viewModel.pendingUserMessage?.quotedContent)

        await gate.open()
        await sendTask.value
    }

    func test_load_populatesMessagesAndRestoresSummaryStoreWithUserUtterancesOnly() async {
        let repository = MockConversationRepository()
        let userMessage = Message(id: 1, conversationId: 10, sender: .user, content: "사용자 발화", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        let characterMessage = Message(id: 2, conversationId: 10, sender: .character(.sadness), content: "캐릭터 답장", repliesToMessageId: 1, createdAt: Date(timeIntervalSince1970: 0))
        repository.stubbedMessages = [userMessage, characterMessage]
        let summaryStore = MockConversationSummaryStore()
        let viewModel = makeViewModel(repository: repository, summaryStore: summaryStore)

        await viewModel.load(conversationId: 10)

        XCTAssertEqual(viewModel.messages, [userMessage, characterMessage])
        let restored = await summaryStore.restoredHistories
        XCTAssertEqual(restored, [["사용자 발화"]], "재진입 복원은 사용자 발화만 summaryStore에 넘겨야 함")
    }

    func test_start_withInitialSentMessage_seedsWithoutLoadingHistory() async {
        let repository = MockConversationRepository()
        let sentMessage = Message(id: 1, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        let initialSentMessage = SentMessage(message: sentMessage, commentStatus: .done, comments: [])
        let viewModel = makeViewModel(repository: repository, conversationId: 10, initialSentMessage: initialSentMessage)

        await viewModel.start()

        XCTAssertEqual(viewModel.messages, [sentMessage])
        XCTAssertEqual(repository.getMessagesCallCount, 0, "initialSentMessage가 있으면 히스토리를 다시 조회하면 안 됨")
    }

    func test_start_withConversationIdOnly_loadsHistory() async {
        let repository = MockConversationRepository()
        let userMessage = Message(id: 1, conversationId: 10, sender: .user, content: "사용자 발화", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        repository.stubbedMessages = [userMessage]
        let viewModel = makeViewModel(repository: repository, conversationId: 10)

        await viewModel.start()

        XCTAssertEqual(viewModel.messages, [userMessage])
        XCTAssertEqual(repository.getMessagesCallCount, 1)
    }

    func test_start_withNeitherConversationIdNorInitialSentMessage_doesNothing() async {
        let repository = MockConversationRepository()
        let viewModel = makeViewModel(repository: repository)

        await viewModel.start()

        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertEqual(repository.getMessagesCallCount, 0)
    }

    func test_updateInput_trailingNewline_keepsNewlineAndDoesNotSignalKeyboardDismiss() {
        let viewModel = makeViewModel()

        let shouldDismiss = viewModel.updateInput("안녕\n")

        XCTAssertFalse(shouldDismiss)
        XCTAssertEqual(viewModel.input, "안녕\n")
    }

    func test_updateInput_overMaxLength_truncatesToMaxLength() {
        let viewModel = makeViewModel()
        let overLong = String(repeating: "가", count: ConversationSummaryPolicy.maxMessageLength + 10)

        let shouldDismiss = viewModel.updateInput(overLong)

        XCTAssertFalse(shouldDismiss)
        XCTAssertEqual(viewModel.input.count, ConversationSummaryPolicy.maxMessageLength)
    }

    func test_isSendDisabled_trueWhenInputBlank() {
        let viewModel = makeViewModel()
        viewModel.input = "   "

        XCTAssertTrue(viewModel.isSendDisabled)
    }

    func test_isSendDisabled_falseWhenInputHasContent() {
        let viewModel = makeViewModel()
        viewModel.input = "안녕"

        XCTAssertFalse(viewModel.isSendDisabled)
    }

    func test_canEndConversation_falseWithoutConversationId() {
        let viewModel = makeViewModel(conversationId: nil)

        XCTAssertFalse(viewModel.canEndConversation)
    }

    func test_requestEndConversation_presentsConfirmation() {
        let viewModel = makeViewModel(conversationId: 10)

        viewModel.requestEndConversation()

        XCTAssertTrue(viewModel.isEndConfirmationPresented)
    }

    func test_confirmEndConversation_onSuccess_endsThenCreatesCardAndDisablesComposer() async {
        let repository = MockConversationRepository()
        let cardRepository = MockCardRepository()
        let card = Card(id: 1, conversationId: 10, emotion: .joy, summary: "요약", message: "메시지", date: Date(timeIntervalSince1970: 0))
        cardRepository.stubbedResult = .success(card)
        let summaryStore = MockConversationSummaryStore()
        summaryStore.stubbedCurrent = "압축본"
        let viewModel = makeViewModel(repository: repository, cardRepository: cardRepository, summaryStore: summaryStore, conversationId: 10)

        await viewModel.confirmEndConversation()

        XCTAssertEqual(repository.endConversationCallCount, 1)
        XCTAssertEqual(repository.receivedEndConversationId, 10)
        XCTAssertTrue(viewModel.isConversationEnded)
        XCTAssertTrue(viewModel.isSendDisabled, "종료된 대화는 전송도 막혀야 함")
        XCTAssertEqual(viewModel.createdCard, card)
        XCTAssertEqual(cardRepository.receivedSummary, "압축본")
    }

    func test_confirmEndConversation_usesDominantCharacterEmotionFromMessages() async {
        let repository = MockConversationRepository()
        repository.stubbedMessages = [
            Message(id: 1, conversationId: 10, sender: .character(.anger), content: "", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0)),
            Message(id: 2, conversationId: 10, sender: .character(.anger), content: "", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0)),
        ]
        let cardRepository = MockCardRepository()
        cardRepository.stubbedResult = .success(Card(id: 1, conversationId: 10, emotion: .anger, summary: "", message: "", date: Date(timeIntervalSince1970: 0)))
        let viewModel = makeViewModel(repository: repository, cardRepository: cardRepository, conversationId: 10)
        await viewModel.load(conversationId: 10)

        await viewModel.confirmEndConversation()

        XCTAssertEqual(cardRepository.receivedEmotion, .anger)
    }

    func test_confirmEndConversation_endConversationFails_doesNotCreateCard() async {
        let repository = MockConversationRepository()
        repository.stubbedEndConversationResult = .failure(SummaryError.inferenceFailed())
        let cardRepository = MockCardRepository()
        let viewModel = makeViewModel(repository: repository, cardRepository: cardRepository, conversationId: 10)

        await viewModel.confirmEndConversation()

        XCTAssertEqual(cardRepository.createCardCallCount, 0)
        XCTAssertFalse(viewModel.isConversationEnded)
        XCTAssertNotNil(viewModel.alertMessage)
    }

    func test_confirmEndConversation_createCardFails_keepsConversationEndedAndSetsAlert() async {
        let repository = MockConversationRepository()
        let cardRepository = MockCardRepository()
        cardRepository.stubbedResult = .failure(SummaryError.inferenceFailed())
        let viewModel = makeViewModel(repository: repository, cardRepository: cardRepository, conversationId: 10)

        await viewModel.confirmEndConversation()

        XCTAssertTrue(viewModel.isConversationEnded, "endConversation은 이미 성공했으므로 대화는 종료 상태로 유지되어야 함")
        XCTAssertNil(viewModel.createdCard)
        XCTAssertNotNil(viewModel.alertMessage)
    }

    func test_retryCreateCard_onlyRetriesCardCreationNotEndConversation() async {
        let repository = MockConversationRepository()
        let cardRepository = MockCardRepository()
        cardRepository.stubbedResult = .failure(SummaryError.inferenceFailed())
        let viewModel = makeViewModel(repository: repository, cardRepository: cardRepository, conversationId: 10)
        await viewModel.confirmEndConversation()
        XCTAssertEqual(repository.endConversationCallCount, 1)

        let card = Card(id: 1, conversationId: 10, emotion: nil, summary: "", message: "", date: Date(timeIntervalSince1970: 0))
        cardRepository.stubbedResult = .success(card)
        await viewModel.retryCreateCard()

        XCTAssertEqual(repository.endConversationCallCount, 1, "endConversation은 재호출되면 안 됨")
        XCTAssertEqual(cardRepository.createCardCallCount, 2)
        XCTAssertEqual(viewModel.createdCard, card)
    }

    func test_dismissCard_clearsCreatedCard() async {
        let cardRepository = MockCardRepository()
        cardRepository.stubbedResult = .success(Card(id: 1, conversationId: 10, emotion: nil, summary: "", message: "", date: Date(timeIntervalSince1970: 0)))
        let viewModel = makeViewModel(cardRepository: cardRepository, conversationId: 10)
        await viewModel.confirmEndConversation()
        XCTAssertNotNil(viewModel.createdCard)

        viewModel.dismissCard()

        XCTAssertNil(viewModel.createdCard)
    }

    func test_isAtBottom_defaultsToTrue() {
        let viewModel = makeViewModel()

        XCTAssertTrue(viewModel.isAtBottom)
    }

    func test_markAtBottom_true_clearsUnseenIncomingMessage() {
        let viewModel = makeViewModel()
        let characterMessage = Message(id: 2, conversationId: 10, sender: .character(.joy), content: "안녕", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        viewModel.markAtBottom(false)
        viewModel.handleNewLastMessage(characterMessage)
        XCTAssertNotNil(viewModel.unseenIncomingMessage)

        viewModel.markAtBottom(true)

        XCTAssertTrue(viewModel.isAtBottom)
        XCTAssertNil(viewModel.unseenIncomingMessage)
    }

    func test_markAtBottom_false_doesNotTouchUnseenIncomingMessage() {
        let viewModel = makeViewModel()

        viewModel.markAtBottom(false)

        XCTAssertFalse(viewModel.isAtBottom)
        XCTAssertNil(viewModel.unseenIncomingMessage)
    }

    func test_handleNewLastMessage_whenAtBottom_returnsTrueAndDoesNotSetUnseen() {
        let viewModel = makeViewModel()
        let characterMessage = Message(id: 2, conversationId: 10, sender: .character(.joy), content: "안녕", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))

        let shouldScroll = viewModel.handleNewLastMessage(characterMessage)

        XCTAssertTrue(shouldScroll)
        XCTAssertNil(viewModel.unseenIncomingMessage)
    }

    func test_handleNewLastMessage_whenNotAtBottom_characterMessage_returnsFalseAndSetsUnseen() {
        let viewModel = makeViewModel()
        let characterMessage = Message(id: 2, conversationId: 10, sender: .character(.sadness), content: "무슨 일이야", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        viewModel.markAtBottom(false)

        let shouldScroll = viewModel.handleNewLastMessage(characterMessage)

        XCTAssertFalse(shouldScroll)
        XCTAssertEqual(viewModel.unseenIncomingMessage, characterMessage)
    }

    func test_handleNewLastMessage_whenNotAtBottom_secondCharacterMessage_updatesToLatestWithoutAccumulating() {
        let viewModel = makeViewModel()
        let first = Message(id: 2, conversationId: 10, sender: .character(.sadness), content: "무슨 일이야", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        let second = Message(id: 3, conversationId: 10, sender: .character(.joy), content: "괜찮아?", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        viewModel.markAtBottom(false)
        viewModel.handleNewLastMessage(first)

        viewModel.handleNewLastMessage(second)

        XCTAssertEqual(viewModel.unseenIncomingMessage, second, "누적 없이 항상 최신 1개만 유지해야 함")
    }

    func test_handleNewLastMessage_whenNotAtBottom_userMessage_returnsTrueAndDoesNotSetUnseen() {
        let viewModel = makeViewModel()
        let userMessage = Message(id: 2, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        viewModel.markAtBottom(false)

        let shouldScroll = viewModel.handleNewLastMessage(userMessage)

        XCTAssertTrue(shouldScroll, "내 메시지는 최하단 여부와 무관하게 항상 스크롤 신호를 줘야 함")
        XCTAssertNil(viewModel.unseenIncomingMessage)
    }
}
