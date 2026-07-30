//
//  SummaryTestViewModelTests.swift
//  GAMSS
//
//  Created by cchanmi on 7/31/26.
//

import XCTest
@testable import GAMSS

private final class MockSummarizeDiaryUseCase: SummarizeDiaryUseCase {
    var stubbedResult: Result<String?, Error> = .success("요약된 문장")

    func execute(text: String) async throws -> String? {
        try stubbedResult.get()
    }
}

@MainActor
final class SummaryTestViewModelTests: XCTestCase {
    func test_summarize_success_updatesResult() async {
        let useCase = MockSummarizeDiaryUseCase()
        useCase.stubbedResult = .success("짧게 요약된 결과")
        let viewModel = SummaryTestViewModel(summarizeDiaryUseCase: useCase)

        await viewModel.summarize(text: "테스트 일기")

        XCTAssertEqual(viewModel.result, "짧게 요약된 결과")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func test_summarize_failure_setsErrorMessage() async {
        let useCase = MockSummarizeDiaryUseCase()
        useCase.stubbedResult = .failure(DiarySummaryError.inferenceFailed())
        let viewModel = SummaryTestViewModel(summarizeDiaryUseCase: useCase)

        await viewModel.summarize(text: "테스트 일기")

        XCTAssertNil(viewModel.result)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}
