//
//  CreateCardUseCaseTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/15/26.
//

import XCTest
@testable import GAMSS

private final class MockCardRepository: CardRepository {
    var stubbedResult: Result<Card, Error> = .failure(SummaryError.inferenceFailed())
    private(set) var receivedConversationId: Int?
    private(set) var receivedEmotion: EmotionCharacter?
    private(set) var receivedSummary: String?

    func createCard(conversationId: Int, emotion: EmotionCharacter?, summary: String) async throws -> Card {
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

final class CreateCardUseCaseTests: XCTestCase {
    func test_execute_passesAllParametersThroughAndReturnsCard() async throws {
        let repository = MockCardRepository()
        let card = Card(id: 1, conversationId: 10, emotion: .anger, summary: "요약", message: "메시지", date: Date(timeIntervalSince1970: 0))
        repository.stubbedResult = .success(card)
        let useCase = CreateCardUseCase(cardRepository: repository)

        let result = try await useCase.execute(conversationId: 10, emotion: .anger, summary: "요약")

        XCTAssertEqual(result, card)
        XCTAssertEqual(repository.receivedConversationId, 10)
        XCTAssertEqual(repository.receivedEmotion, .anger)
        XCTAssertEqual(repository.receivedSummary, "요약")
    }

    func test_execute_withNilEmotion_passesNilThrough() async throws {
        let repository = MockCardRepository()
        repository.stubbedResult = .success(Card(id: 1, conversationId: 10, emotion: nil, summary: "요약", message: "메시지", date: Date(timeIntervalSince1970: 0)))
        let useCase = CreateCardUseCase(cardRepository: repository)

        _ = try await useCase.execute(conversationId: 10, emotion: nil, summary: "요약")

        XCTAssertNil(repository.receivedEmotion)
    }

    func test_execute_propagatesRepositoryError() async {
        let repository = MockCardRepository()
        repository.stubbedResult = .failure(SummaryError.inferenceFailed())
        let useCase = CreateCardUseCase(cardRepository: repository)

        do {
            _ = try await useCase.execute(conversationId: 10, emotion: nil, summary: "요약")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? SummaryError, .inferenceFailed())
        }
    }
}
