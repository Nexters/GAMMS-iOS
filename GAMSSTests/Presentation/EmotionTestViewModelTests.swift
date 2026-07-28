//
//  EmotionTestViewModelTests.swift
//  GAMSS
//
//  Created by cchanmi on 7/25/26.
//

import XCTest
@testable import GAMSS

private final class MockAnalyzeEmotionUseCase: AnalyzeEmotionUseCase {
    var stubbedResult: Result<EmotionAnalysisResult, Error> = .success(
        EmotionAnalysisResult(emotion: .happy, confidence: 0.9)
    )

    func execute(text: String) async throws -> EmotionAnalysisResult {
        try stubbedResult.get()
    }
}

@MainActor
final class EmotionTestViewModelTests: XCTestCase {
    func test_analyze_success_updatesResult() async {
        let useCase = MockAnalyzeEmotionUseCase()
        useCase.stubbedResult = .success(EmotionAnalysisResult(emotion: .anxious, confidence: 0.6))
        let viewModel = EmotionTestViewModel(analyzeEmotionUseCase: useCase)

        await viewModel.analyze(text: "테스트 문장")

        XCTAssertEqual(viewModel.result, EmotionAnalysisResult(emotion: .anxious, confidence: 0.6))
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func test_analyze_failure_setsErrorMessage() async {
        let useCase = MockAnalyzeEmotionUseCase()
        useCase.stubbedResult = .failure(EmotionAnalysisError.emptyInput)
        let viewModel = EmotionTestViewModel(analyzeEmotionUseCase: useCase)

        await viewModel.analyze(text: "")

        XCTAssertNil(viewModel.result)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}
