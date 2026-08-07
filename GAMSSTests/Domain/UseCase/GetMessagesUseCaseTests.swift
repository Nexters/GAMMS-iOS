//
//  GetMessagesUseCaseTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import XCTest
@testable import GAMSS

private final class MockConversationRepository: ConversationRepository {
    var stubbedMessages: [Message] = []
    private(set) var receivedConversationId: Int?

    func sendMessage(conversationId: Int?, content: String, repliesToMessageId: Int?, contextSummary: String?) async throws -> SentMessage {
        fatalError("not used in this test")
    }

    func getMessages(conversationId: Int) async throws -> [Message] {
        receivedConversationId = conversationId
        return stubbedMessages
    }
}

final class GetMessagesUseCaseTests: XCTestCase {
    func test_execute_returnsMessagesFromRepository() async throws {
        let repository = MockConversationRepository()
        repository.stubbedMessages = [
            Message(id: 1, conversationId: 10, sender: .user, content: "안녕", repliesToMessageId: nil),
            Message(id: 2, conversationId: 10, sender: .character(.joy), content: "반가워", repliesToMessageId: 1),
        ]
        let useCase = GetMessagesUseCase(conversationRepository: repository)

        let result = try await useCase.execute(conversationId: 10)

        XCTAssertEqual(result, repository.stubbedMessages)
        XCTAssertEqual(repository.receivedConversationId, 10)
    }
}
