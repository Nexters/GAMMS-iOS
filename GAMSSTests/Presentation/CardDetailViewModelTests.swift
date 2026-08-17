//
//  CardDetailViewModelTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/17/26.
//

import XCTest
@testable import GAMSS

private final class MockCardRepository: CardRepository {
    var stubbedGetCardResult: Result<Card, Error> = .failure(SummaryError.inferenceFailed())
    var stubbedDeleteCardResult: Result<Void, Error> = .success(())
    private(set) var receivedGetCardId: Int?
    private(set) var receivedDeleteCardId: Int?

    func createCard(conversationId: Int, emotion: EmotionCharacter?, summary: String) async throws -> Card {
        fatalError("사용 안 함")
    }

    func getCard(cardId: Int) async throws -> Card {
        receivedGetCardId = cardId
        return try stubbedGetCardResult.get()
    }

    func deleteCard(cardId: Int) async throws {
        receivedDeleteCardId = cardId
        _ = try stubbedDeleteCardResult.get()
    }
}

@MainActor
final class CardDetailViewModelTests: XCTestCase {
    private func makeViewModel(cardId: Int = 1, repository: MockCardRepository) -> CardDetailViewModel {
        CardDetailViewModel(
            cardId: cardId,
            getCardUseCase: GetCardUseCase(cardRepository: repository),
            deleteCardUseCase: DeleteCardUseCase(cardRepository: repository)
        )
    }

    func test_loadCard_onSuccess_setsCardAndClearsLoading() async {
        let repository = MockCardRepository()
        let card = Card(id: 1, conversationId: 10, emotion: .anger, summary: "요약", message: "메시지", date: Date(timeIntervalSince1970: 0))
        repository.stubbedGetCardResult = .success(card)
        let viewModel = makeViewModel(repository: repository)

        await viewModel.loadCard()

        XCTAssertEqual(viewModel.card, card)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(repository.receivedGetCardId, 1)
    }

    func test_loadCard_onFailure_setsAlertMessageAndClearsLoading() async {
        let repository = MockCardRepository()
        repository.stubbedGetCardResult = .failure(SummaryError.inferenceFailed())
        let viewModel = makeViewModel(repository: repository)

        await viewModel.loadCard()

        XCTAssertEqual(viewModel.alertMessage, "카드를 불러오지 못했어요")
        XCTAssertNil(viewModel.card)
        XCTAssertFalse(viewModel.isLoading)
    }

    func test_isLoadFailureAlert_whenCardIsNilAndAlertMessageSet_isTrue() async {
        let repository = MockCardRepository()
        repository.stubbedGetCardResult = .failure(SummaryError.inferenceFailed())
        let viewModel = makeViewModel(repository: repository)

        await viewModel.loadCard()

        XCTAssertTrue(viewModel.isLoadFailureAlert)
    }

    func test_deleteCard_onSuccess_returnsTrueAndClearsLoading() async {
        let repository = MockCardRepository()
        let card = Card(id: 1, conversationId: 10, emotion: .anger, summary: "요약", message: "메시지", date: Date(timeIntervalSince1970: 0))
        repository.stubbedGetCardResult = .success(card)
        let viewModel = makeViewModel(repository: repository)
        await viewModel.loadCard()

        let succeeded = await viewModel.deleteCard()

        XCTAssertTrue(succeeded)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(repository.receivedDeleteCardId, 1)
    }

    func test_deleteCard_onFailure_returnsFalseAndSetsAlertMessage() async {
        let repository = MockCardRepository()
        repository.stubbedDeleteCardResult = .failure(SummaryError.inferenceFailed())
        let viewModel = makeViewModel(repository: repository)

        let succeeded = await viewModel.deleteCard()

        XCTAssertFalse(succeeded)
        XCTAssertEqual(viewModel.alertMessage, "카드를 삭제하지 못했어요")
    }

    func test_isLoadFailureAlert_afterDeleteFailureWithCardLoaded_isFalse() async {
        let repository = MockCardRepository()
        let card = Card(id: 1, conversationId: 10, emotion: .anger, summary: "요약", message: "메시지", date: Date(timeIntervalSince1970: 0))
        repository.stubbedGetCardResult = .success(card)
        repository.stubbedDeleteCardResult = .failure(SummaryError.inferenceFailed())
        let viewModel = makeViewModel(repository: repository)
        await viewModel.loadCard()

        _ = await viewModel.deleteCard()

        XCTAssertFalse(viewModel.isLoadFailureAlert)
    }
}
