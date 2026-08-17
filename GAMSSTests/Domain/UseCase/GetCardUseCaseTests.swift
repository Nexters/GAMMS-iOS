//
//  GetCardUseCaseTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/17/26.
//

import XCTest
@testable import GAMSS

private final class MockCardRepository: CardRepository {
    var stubbedResult: Result<Card, Error> = .failure(SummaryError.inferenceFailed())
    private(set) var receivedCardId: Int?

    func createCard(conversationId: Int, emotion: EmotionCharacter?, summary: String) async throws -> Card {
        fatalError("사용 안 함")
    }

    func getCard(cardId: Int) async throws -> Card {
        receivedCardId = cardId
        return try stubbedResult.get()
    }

    func deleteCard(cardId: Int) async throws {
        fatalError("사용 안 함")
    }
}

final class GetCardUseCaseTests: XCTestCase {
    func test_execute_passesCardIdThroughAndReturnsCard() async throws {
        let repository = MockCardRepository()
        let card = Card(id: 1, conversationId: 10, emotion: .anger, summary: "요약", message: "메시지", date: Date(timeIntervalSince1970: 0))
        repository.stubbedResult = .success(card)
        let useCase = GetCardUseCase(cardRepository: repository)

        let result = try await useCase.execute(cardId: 1)

        XCTAssertEqual(result, card)
        XCTAssertEqual(repository.receivedCardId, 1)
    }

    func test_execute_propagatesRepositoryError() async {
        let repository = MockCardRepository()
        repository.stubbedResult = .failure(SummaryError.inferenceFailed())
        let useCase = GetCardUseCase(cardRepository: repository)

        do {
            _ = try await useCase.execute(cardId: 1)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? SummaryError, .inferenceFailed())
        }
    }
}
