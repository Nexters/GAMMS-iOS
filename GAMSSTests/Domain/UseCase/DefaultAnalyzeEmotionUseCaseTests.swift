//
//  DefaultAnalyzeEmotionUseCaseTests.swift
//  GAMSS
//
//  Created by cchanmi on 7/24/26.
//

import XCTest
@testable import GAMSS

private final class MockEmotionAnalysisRepository: EmotionAnalysisRepository {
    var stubbedResult: Result<EmotionAnalysisResult, Error> = .success(
        EmotionAnalysisResult(emotion: .happy, confidence: 0.9)
    )
    private(set) var receivedText: String?

    func analyze(text: String) async throws -> EmotionAnalysisResult {
        receivedText = text
        return try stubbedResult.get()
    }
}

final class DefaultAnalyzeEmotionUseCaseTests: XCTestCase {
    func test_execute_forwardsTextAndReturnsRepositoryResult() async throws {
        let repository = MockEmotionAnalysisRepository()
        repository.stubbedResult = .success(EmotionAnalysisResult(emotion: .sad, confidence: 0.75))
        let useCase = DefaultAnalyzeEmotionUseCase(emotionAnalysisRepository: repository)

        let result = try await useCase.execute(text: "오늘은 조금 우울하다")

        XCTAssertEqual(repository.receivedText, "오늘은 조금 우울하다")
        XCTAssertEqual(result, EmotionAnalysisResult(emotion: .sad, confidence: 0.75))
    }

    func test_execute_propagatesRepositoryError() async {
        let repository = MockEmotionAnalysisRepository()
        repository.stubbedResult = .failure(EmotionAnalysisError.emptyInput)
        let useCase = DefaultAnalyzeEmotionUseCase(emotionAnalysisRepository: repository)

        do {
            _ = try await useCase.execute(text: "")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? EmotionAnalysisError, .emptyInput)
        }
    }
}
