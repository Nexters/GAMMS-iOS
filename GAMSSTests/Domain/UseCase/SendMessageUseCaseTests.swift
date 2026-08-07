//
//  SendMessageUseCaseTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import XCTest
@testable import GAMSS

private final class MockConversationRepository: ConversationRepository {
    var stubbedSendResult: Result<SentMessage, Error> = .failure(SummaryError.inferenceFailed())
    private(set) var receivedConversationId: Int?
    private(set) var receivedContent: String?
    private(set) var receivedRepliesToMessageId: Int?
    private(set) var receivedContextSummary: String?

    func sendMessage(conversationId: Int?, content: String, repliesToMessageId: Int?, contextSummary: String?) async throws -> SentMessage {
        receivedConversationId = conversationId
        receivedContent = content
        receivedRepliesToMessageId = repliesToMessageId
        receivedContextSummary = contextSummary
        return try stubbedSendResult.get()
    }

    func getMessages(conversationId: Int) async throws -> [Message] {
        []
    }
}

final class SendMessageUseCaseTests: XCTestCase {
    func test_execute_passesAllParametersThrough() async throws {
        let repository = MockConversationRepository()
        let sent = SentMessage(
            message: Message(id: 1, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil),
            commentStatus: .done,
            comments: []
        )
        repository.stubbedSendResult = .success(sent)
        let useCase = SendMessageUseCase(conversationRepository: repository)

        let result = try await useCase.execute(conversationId: 10, content: "안녕", repliesToMessageId: 5, contextSummary: "압축본")

        XCTAssertEqual(result, sent)
        XCTAssertEqual(repository.receivedConversationId, 10)
        XCTAssertEqual(repository.receivedContent, "안녕")
        XCTAssertEqual(repository.receivedRepliesToMessageId, 5)
        XCTAssertEqual(repository.receivedContextSummary, "압축본")
    }

    func test_execute_propagatesRepositoryError() async {
        let repository = MockConversationRepository()
        repository.stubbedSendResult = .failure(SummaryError.inferenceFailed())
        let useCase = SendMessageUseCase(conversationRepository: repository)

        do {
            _ = try await useCase.execute(conversationId: nil, content: "안녕", repliesToMessageId: nil, contextSummary: nil)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? SummaryError, .inferenceFailed())
        }
    }
}
