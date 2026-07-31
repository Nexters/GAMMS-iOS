//
//  SummaryTestViewModelTests.swift
//  GAMSS
//
//  Created by cchanmi on 7/31/26.
//

import XCTest
@testable import GAMSS

private actor MockSummarizeDiaryUseCase: SummarizeDiaryUseCase {
    private var stubbedResult: Result<String?, Error> = .success("요약된 문장")

    func setStubbedResult(_ result: Result<String?, Error>) {
        stubbedResult = result
    }

    func addUtterance(_ text: String) {}

    func finalize() async throws -> String? {
        try stubbedResult.get()
    }
}

@MainActor
final class SummaryTestViewModelTests: XCTestCase {
    func test_addUtterance_appendsToDisplayedList() async {
        let useCase = MockSummarizeDiaryUseCase()
        let viewModel = SummaryTestViewModel(summarizeDiaryUseCase: useCase)

        await viewModel.addUtterance("첫 문장")
        await viewModel.addUtterance("둘째 문장")

        XCTAssertEqual(viewModel.utterances, ["첫 문장", "둘째 문장"])
    }

    func test_addUtterance_blankText_isIgnored() async {
        let useCase = MockSummarizeDiaryUseCase()
        let viewModel = SummaryTestViewModel(summarizeDiaryUseCase: useCase)

        await viewModel.addUtterance("   ")

        XCTAssertTrue(viewModel.utterances.isEmpty)
    }

    func test_finalizeSession_success_updatesResultAndClearsUtterances() async {
        let useCase = MockSummarizeDiaryUseCase()
        await useCase.setStubbedResult(.success("짧게 요약된 결과"))
        let viewModel = SummaryTestViewModel(summarizeDiaryUseCase: useCase)
        await viewModel.addUtterance("테스트 일기")

        await viewModel.finalizeSession()

        XCTAssertEqual(viewModel.result, "짧게 요약된 결과")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.utterances.isEmpty)
    }

    func test_finalizeSession_failure_setsErrorMessage() async {
        let useCase = MockSummarizeDiaryUseCase()
        await useCase.setStubbedResult(.failure(DiarySummaryError.inferenceFailed()))
        let viewModel = SummaryTestViewModel(summarizeDiaryUseCase: useCase)
        await viewModel.addUtterance("테스트 일기")

        await viewModel.finalizeSession()

        XCTAssertNil(viewModel.result)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}
