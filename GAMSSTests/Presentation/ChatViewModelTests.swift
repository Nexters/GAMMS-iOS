//
//  ChatViewModelTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import XCTest
@testable import GAMSS

private final class MockConversationRepository: ConversationRepository {
    var stubbedSendResult: Result<SentMessage, Error> = .failure(SummaryError.inferenceFailed())
    var stubbedMessages: [Message] = []
    private(set) var sendCallCount = 0
    private(set) var getMessagesCallCount = 0
    private(set) var receivedContextSummary: String?

    func sendMessage(conversationId: Int?, content: String, repliesToMessageId: Int?, contextSummary: String?) async throws -> SentMessage {
        sendCallCount += 1
        receivedContextSummary = contextSummary
        return try stubbedSendResult.get()
    }

    func getMessages(conversationId: Int) async throws -> [Message] {
        getMessagesCallCount += 1
        return stubbedMessages
    }

    func getConversations(date: String) async throws -> [ConversationSummary] {
        []
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
        summaryStore: MockConversationSummaryStore = MockConversationSummaryStore(),
        conversationId: Int? = nil,
        initialSentMessage: SentMessage? = nil
    ) -> ChatViewModel {
        ChatViewModel(
            sendMessageUseCase: SendMessageUseCase(conversationRepository: repository),
            getMessagesUseCase: GetMessagesUseCase(conversationRepository: repository),
            summaryStore: summaryStore,
            conversationId: conversationId,
            initialSentMessage: initialSentMessage
        )
    }

    func test_send_onSuccess_appendsSentMessageAndFirstCommentImmediately() async {
        let repository = MockConversationRepository()
        let sentMessage = Message(id: 1, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil)
        let comment1 = Message(id: 2, conversationId: 10, sender: .character(.joy), content: "반가워", repliesToMessageId: 1)
        let comment2 = Message(id: 3, conversationId: 10, sender: .character(.joy), content: "오늘 어때?", repliesToMessageId: 1)
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
        let sentMessage = Message(id: 1, conversationId: 10, sender: .user, content: "오늘 힘들었어", repliesToMessageId: nil)
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
            message: Message(id: 1, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil),
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
        let sentMessage = Message(id: 1, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil)
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

    func test_load_populatesMessagesAndRestoresSummaryStoreWithUserUtterancesOnly() async {
        let repository = MockConversationRepository()
        let userMessage = Message(id: 1, conversationId: 10, sender: .user, content: "사용자 발화", repliesToMessageId: nil)
        let characterMessage = Message(id: 2, conversationId: 10, sender: .character(.sadness), content: "캐릭터 답장", repliesToMessageId: 1)
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
        let sentMessage = Message(id: 1, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil)
        let initialSentMessage = SentMessage(message: sentMessage, commentStatus: .done, comments: [])
        let viewModel = makeViewModel(repository: repository, conversationId: 10, initialSentMessage: initialSentMessage)

        await viewModel.start()

        XCTAssertEqual(viewModel.messages, [sentMessage])
        XCTAssertEqual(repository.getMessagesCallCount, 0, "initialSentMessage가 있으면 히스토리를 다시 조회하면 안 됨")
    }

    func test_start_withConversationIdOnly_loadsHistory() async {
        let repository = MockConversationRepository()
        let userMessage = Message(id: 1, conversationId: 10, sender: .user, content: "사용자 발화", repliesToMessageId: nil)
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

    func test_updateInput_trailingNewline_stripsNewlineAndSignalsKeyboardDismiss() {
        let viewModel = makeViewModel()

        let shouldDismiss = viewModel.updateInput("안녕\n")

        XCTAssertTrue(shouldDismiss)
        XCTAssertEqual(viewModel.input, "안녕")
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
}
