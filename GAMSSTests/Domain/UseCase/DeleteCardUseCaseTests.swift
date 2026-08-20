//
//  DeleteCardUseCaseTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/17/26.
//

import XCTest
@testable import GAMSS

private final class MockCardRepository: CardRepository {
    var stubbedError: Error?
    private(set) var receivedCardId: Int?

    func createCard(conversationId: Int, emotion: EmotionCharacter?, summary: String) async throws -> Card {
        fatalError("사용 안 함")
    }

    func getCard(cardId: Int) async throws -> Card {
        fatalError("사용 안 함")
    }

    func deleteCard(cardId: Int) async throws {
        receivedCardId = cardId
        if let stubbedError {
            throw stubbedError
        }
    }

    func fetchCardsByDate(yearMonth: Date, emotion: Emotion) async throws -> [DailyEmotion] {
        fatalError("사용 안 함")
    }

    func deleteAllCard() async throws {
        fatalError("사용 안 함")
    }
}

final class DeleteCardUseCaseTests: XCTestCase {
    func test_execute_passesCardIdThrough() async throws {
        let repository = MockCardRepository()
        let useCase = DeleteCardUseCase(cardRepository: repository)

        try await useCase.execute(cardId: 1)

        XCTAssertEqual(repository.receivedCardId, 1)
    }

    func test_execute_propagatesRepositoryError() async {
        let repository = MockCardRepository()
        repository.stubbedError = SummaryError.inferenceFailed()
        let useCase = DeleteCardUseCase(cardRepository: repository)

        do {
            try await useCase.execute(cardId: 1)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? SummaryError, .inferenceFailed())
        }
    }
}
