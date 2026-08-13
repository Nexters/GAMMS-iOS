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
    private(set) var sendCallCount = 0

    func sendMessage(conversationId: Int?, content: String, repliesToMessageId: Int?, contextSummary: String?) async throws -> SentMessage {
        sendCallCount += 1
        return try stubbedSendResult.get()
    }

    func getMessages(conversationId: Int) async throws -> [Message] {
        []
    }

    func getIncompleteConversations() async throws -> [ConversationSummary] {
        []
    }
}

@MainActor
final class HomeViewModelTests: XCTestCase {
    private func makeViewModel(repository: MockConversationRepository = MockConversationRepository()) -> HomeViewModel {
        HomeViewModel(sendMessageUseCase: SendMessageUseCase(conversationRepository: repository))
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

    func test_toggleEmotion_lastRemainingSelection_isIgnored() {
        let viewModel = makeViewModel()
        for emotion in EmotionCharacter.allCases where emotion != .joy {
            viewModel.toggleEmotion(emotion)
        }
        XCTAssertEqual(viewModel.selectedEmotions, [.joy], "사전 조건: 마지막 1개(joy)만 남아있어야 함")

        viewModel.toggleEmotion(.joy)

        XCTAssertEqual(viewModel.selectedEmotions, [.joy], "마지막 1개는 해제할 수 없어야 함")
    }

    func test_isEmotionPickerOpen_defaultsToFalse() {
        let viewModel = makeViewModel()

        XCTAssertFalse(viewModel.isEmotionPickerOpen)
    }
}
