//
//  ConversationListViewModelTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import XCTest
@testable import GAMSS

private final class MockConversationRepository: ConversationRepository {
    var stubbedGetConversationsResult: Result<[ConversationSummary], Error> = .success([])

    func sendMessage(conversationId: Int?, content: String, repliesToMessageId: Int?, contextSummary: String?) async throws -> SentMessage {
        fatalError("사용 안 함")
    }

    func getMessages(conversationId: Int) async throws -> [Message] {
        []
    }

    func getIncompleteConversations() async throws -> [ConversationSummary] {
        try stubbedGetConversationsResult.get()
    }

    func updateTitle(conversationId: Int, title: String) async throws {
        fatalError("사용 안 함")
    }
}

@MainActor
final class ConversationListViewModelTests: XCTestCase {
    private func makeViewModel(repository: MockConversationRepository = MockConversationRepository()) -> ConversationListViewModel {
        ConversationListViewModel(getIncompleteConversationsUseCase: GetIncompleteConversationsUseCase(conversationRepository: repository))
    }

    func test_load_onSuccess_setsConversationsAndClearsLoading() async {
        let repository = MockConversationRepository()
        let summary = ConversationSummary(id: 1, title: "제목", status: "ACTIVE", createdAt: Date(timeIntervalSince1970: 0))
        repository.stubbedGetConversationsResult = .success([summary])
        let viewModel = makeViewModel(repository: repository)

        await viewModel.load()

        XCTAssertEqual(viewModel.conversations, [summary])
        XCTAssertFalse(viewModel.isLoading)
    }

    func test_load_onFailure_setsAlertMessageAndClearsLoading() async {
        let repository = MockConversationRepository()
        repository.stubbedGetConversationsResult = .failure(SummaryError.inferenceFailed())
        let viewModel = makeViewModel(repository: repository)

        await viewModel.load()

        XCTAssertEqual(viewModel.alertMessage, "채팅방 목록을 불러오지 못했어요")
        XCTAssertFalse(viewModel.isLoading)
    }
}
