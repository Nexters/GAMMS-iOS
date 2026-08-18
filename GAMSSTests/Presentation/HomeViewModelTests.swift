//
//  HomeViewModelTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/10/26.
//

import XCTest
@testable import GAMSS

private final class MockConversationRepository: ConversationRepository {
    var stubbedSendResult: Result<SentMessage, Error> = .failure(SummaryError.inferenceFailed())
    var stubbedUpdateTitleResult: Result<Void, Error> = .success(())
    private(set) var sendCallCount = 0
    private(set) var receivedExcludedCharacters: Set<EmotionCharacter>?
    private(set) var receivedTitleConversationId: Int?
    private(set) var receivedTitle: String?

    func sendMessage(conversationId: Int?, content: String, repliesToMessageId: Int?, contextSummary: String?, excludedCharacters: Set<EmotionCharacter>) async throws -> SentMessage {
        sendCallCount += 1
        receivedExcludedCharacters = excludedCharacters
        return try stubbedSendResult.get()
    }

    func getMessages(conversationId: Int) async throws -> [Message] {
        []
    }

    func getIncompleteConversations() async throws -> [ConversationSummary] {
        []
    }

    func updateTitle(conversationId: Int, title: String) async throws {
        receivedTitleConversationId = conversationId
        receivedTitle = title
        _ = try stubbedUpdateTitleResult.get()
    }

    func endConversation(conversationId: Int) async throws {
        fatalError("not used in this test")
    }

    func deleteConversations(_ ids: [Int]) async throws {
        fatalError("not used in this test")
    }

    func searchConversations(_ text: String) async throws -> SearchChatResponseDTO {
        fatalError("not used in this test")
    }
}

private final class MockFetchMyProfileUseCase: FetchMyProfileUseCase {
    var stubbedResult: Result<User, Error> = .failure(SummaryError.inferenceFailed())
    private(set) var executeCallCount = 0

    func execute() async throws -> User {
        executeCallCount += 1
        return try stubbedResult.get()
    }
}

@MainActor
final class HomeViewModelTests: XCTestCase {
    private func makeViewModel(
        repository: MockConversationRepository = MockConversationRepository(),
        fetchMyProfileUseCase: MockFetchMyProfileUseCase = MockFetchMyProfileUseCase(),
        userManager: UserManager = UserManager()
    ) -> HomeViewModel {
        HomeViewModel(
            sendMessageUseCase: SendMessageUseCase(conversationRepository: repository),
            fetchMyProfileUseCase: fetchMyProfileUseCase,
            updateConversationTitleUseCase: UpdateConversationTitleUseCase(conversationRepository: repository),
            userManager: userManager
        )
    }

    func test_send_onSuccess_setsCreatedConversationIdAndClearsInput() async {
        let repository = MockConversationRepository()
        let sentMessage = Message(id: 1, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        repository.stubbedSendResult = .success(SentMessage(message: sentMessage, commentStatus: .done, comments: []))
        let viewModel = makeViewModel(repository: repository)
        viewModel.input = "안녕"

        await viewModel.send()

        XCTAssertEqual(viewModel.createdConversationId, 10)
        XCTAssertEqual(viewModel.input, "")
    }

    func test_send_contentTooLong_setsValidationAlertAndDoesNotCallRepository() async {
        let repository = MockConversationRepository()
        let viewModel = makeViewModel(repository: repository)
        viewModel.input = String(repeating: "가", count: ConversationSummaryPolicy.maxMessageLength + 1)

        await viewModel.send()

        XCTAssertEqual(repository.sendCallCount, 0, "최종 검증에 걸리면 네트워크 호출까지 가면 안 됨")
        XCTAssertEqual(viewModel.alertMessage, SendMessageValidationError.tooLong.errorDescription)
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

    func test_selectedEmotions_defaultsToAllSixCharacters() {
        let viewModel = makeViewModel()

        XCTAssertEqual(viewModel.selectedEmotions, Set(EmotionCharacter.allCases))
    }

    func test_toggleEmotion_deselectsWhenMoreThanOneRemainsSelected() {
        let viewModel = makeViewModel()

        viewModel.toggleEmotion(.joy)

        XCTAssertFalse(viewModel.selectedEmotions.contains(.joy))
        XCTAssertEqual(viewModel.selectedEmotions.count, 5)
    }

    func test_toggleEmotion_reselectsAfterBeingDeselected() {
        let viewModel = makeViewModel()
        viewModel.toggleEmotion(.joy)

        viewModel.toggleEmotion(.joy)

        XCTAssertTrue(viewModel.selectedEmotions.contains(.joy))
        XCTAssertEqual(viewModel.selectedEmotions.count, 6)
    }

    func test_toggleEmotion_lastRemainingSelection_isAllowed_resultsInEmptySelection() {
        let viewModel = makeViewModel()
        for emotion in EmotionCharacter.allCases where emotion != .joy {
            viewModel.toggleEmotion(emotion)
        }
        XCTAssertEqual(viewModel.selectedEmotions, [.joy], "사전 조건: 마지막 1개(joy)만 남아있어야 함")

        viewModel.toggleEmotion(.joy)

        XCTAssertTrue(viewModel.selectedEmotions.isEmpty, "전체 해제가 허용되어야 함")
    }

    func test_isEmotionPickerOpen_defaultsToFalse() {
        let viewModel = makeViewModel()

        XCTAssertFalse(viewModel.isEmotionPickerOpen)
    }

    func test_loadProfileIfNeeded_whenUserAlreadySet_doesNotCallUseCase() async {
        let useCase = MockFetchMyProfileUseCase()
        let userManager = UserManager()
        userManager.user = User(id: 1, email: "a@b.com", name: "기존", nickname: "기존닉네임")
        let viewModel = makeViewModel(fetchMyProfileUseCase: useCase, userManager: userManager)

        await viewModel.loadProfileIfNeeded()

        XCTAssertEqual(useCase.executeCallCount, 0, "이미 값이 있으면 재조회하면 안 됨")
        XCTAssertEqual(userManager.user?.nickname, "기존닉네임")
    }

    func test_loadProfileIfNeeded_whenUserNil_fetchesAndSetsUserManagerUser() async {
        let useCase = MockFetchMyProfileUseCase()
        useCase.stubbedResult = .success(User(id: 1, email: "a@b.com", name: "햄스터", nickname: "햄스터"))
        let userManager = UserManager()
        let viewModel = makeViewModel(fetchMyProfileUseCase: useCase, userManager: userManager)

        await viewModel.loadProfileIfNeeded()

        XCTAssertEqual(useCase.executeCallCount, 1)
        XCTAssertEqual(userManager.user?.nickname, "햄스터")
    }

    func test_loadProfileIfNeeded_onFailure_setsAlertMessage() async {
        let useCase = MockFetchMyProfileUseCase()
        useCase.stubbedResult = .failure(SummaryError.inferenceFailed())
        let userManager = UserManager()
        let viewModel = makeViewModel(fetchMyProfileUseCase: useCase, userManager: userManager)

        await viewModel.loadProfileIfNeeded()

        XCTAssertNotNil(viewModel.alertMessage)
        XCTAssertNil(userManager.user)
    }

    func test_send_onSuccess_updatesTitleWithSentContentInBackground() async {
        let repository = MockConversationRepository()
        let sentMessage = Message(id: 1, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        repository.stubbedSendResult = .success(SentMessage(message: sentMessage, commentStatus: .done, comments: []))
        let viewModel = makeViewModel(repository: repository)
        viewModel.input = "안녕"

        await viewModel.send()
        await viewModel.pendingTitleUpdateTask?.value

        XCTAssertEqual(repository.receivedTitleConversationId, 10)
        XCTAssertEqual(repository.receivedTitle, "안녕")
        XCTAssertNil(viewModel.alertMessage, "title 저장 성공 시에는 알림이 뜨면 안 됨")
    }

    func test_send_onSuccess_titleUpdateFails_setsAlertMessageWithoutClearingCreatedConversationId() async {
        let repository = MockConversationRepository()
        let sentMessage = Message(id: 1, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        repository.stubbedSendResult = .success(SentMessage(message: sentMessage, commentStatus: .done, comments: []))
        repository.stubbedUpdateTitleResult = .failure(SummaryError.inferenceFailed())
        let viewModel = makeViewModel(repository: repository)
        viewModel.input = "안녕"

        await viewModel.send()
        await viewModel.pendingTitleUpdateTask?.value

        XCTAssertEqual(viewModel.createdConversationId, 10, "title 저장이 실패해도 이미 트리거된 네비게이션은 유지돼야 함")
        XCTAssertNotNil(viewModel.alertMessage)
    }

    func test_send_excludesDeselectedEmotionsOnly() async {
        let repository = MockConversationRepository()
        let sentMessage = Message(id: 1, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil, createdAt: Date(timeIntervalSince1970: 0))
        repository.stubbedSendResult = .success(SentMessage(message: sentMessage, commentStatus: .done, comments: []))
        let viewModel = makeViewModel(repository: repository)
        viewModel.input = "안녕"
        viewModel.toggleEmotion(.anger)
        viewModel.toggleEmotion(.quirky)

        await viewModel.send()

        XCTAssertEqual(repository.receivedExcludedCharacters, [.anger, .quirky])
    }

    func test_isSendDisabled_trueWhenAllEmotionsDeselected_evenWithInput() {
        let viewModel = makeViewModel()
        viewModel.input = "안녕"
        for emotion in EmotionCharacter.allCases {
            viewModel.toggleEmotion(emotion)
        }

        XCTAssertTrue(viewModel.selectedEmotions.isEmpty, "사전 조건: 전체 해제 상태여야 함")
        XCTAssertTrue(viewModel.isSendDisabled, "감정을 전체 제외하면 입력이 있어도 전송은 막혀야 함")
    }
}
