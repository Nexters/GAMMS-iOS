//
//  DefaultSummarizeDiaryUseCaseTests.swift
//  GAMSS
//
//  Created by cchanmi on 7/29/26.
//

import XCTest
@testable import GAMSS

private final class MockDiarySummaryRepository: DiarySummaryRepository {
    var stubbedResult: Result<String, Error> = .success("요약된 문장")
    private(set) var receivedText: String?

    func summarize(text: String) async throws -> String {
        receivedText = text
        return try stubbedResult.get()
    }
}

final class DefaultSummarizeDiaryUseCaseTests: XCTestCase {
    func test_finalize_withNoUtterances_returnsNilWithoutCallingRepository() async throws {
        let repository = MockDiarySummaryRepository()
        let useCase = DefaultSummarizeDiaryUseCase(diarySummaryRepository: repository)

        let result = try await useCase.finalize()

        XCTAssertNil(result)
        XCTAssertNil(repository.receivedText)
    }

    func test_finalize_withOnlyBlankUtterances_returnsNilWithoutCallingRepository() async throws {
        let repository = MockDiarySummaryRepository()
        let useCase = DefaultSummarizeDiaryUseCase(diarySummaryRepository: repository)

        await useCase.addUtterance("   ")
        await useCase.addUtterance("")

        let result = try await useCase.finalize()

        XCTAssertNil(result)
        XCTAssertNil(repository.receivedText)
    }

    func test_finalize_shortAccumulatedText_returnsJoinedTextWithoutCallingRepository() async throws {
        let repository = MockDiarySummaryRepository()
        let useCase = DefaultSummarizeDiaryUseCase(diarySummaryRepository: repository)

        await useCase.addUtterance("오늘 아침에 늦잠 잤어")
        await useCase.addUtterance("그래서 회의에 지각했어")

        let result = try await useCase.finalize()

        XCTAssertEqual(result, "오늘 아침에 늦잠 잤어\n그래서 회의에 지각했어")
        XCTAssertNil(repository.receivedText)
    }

    func test_finalize_longAccumulatedText_returnsRepositoryResult() async throws {
        let repository = MockDiarySummaryRepository()
        repository.stubbedResult = .success("요약됨")
        let useCase = DefaultSummarizeDiaryUseCase(diarySummaryRepository: repository)
        let firstHalf = String(repeating: "가", count: 70)
        let secondHalf = String(repeating: "나", count: 70)

        await useCase.addUtterance(firstHalf)
        await useCase.addUtterance(secondHalf)

        let result = try await useCase.finalize()

        XCTAssertEqual(result, "요약됨")
        XCTAssertEqual(repository.receivedText, "\(firstHalf)\n\(secondHalf)")
    }

    func test_finalize_propagatesRepositoryError() async {
        let repository = MockDiarySummaryRepository()
        repository.stubbedResult = .failure(DiarySummaryError.inferenceFailed())
        let useCase = DefaultSummarizeDiaryUseCase(diarySummaryRepository: repository)
        await useCase.addUtterance(String(repeating: "가", count: 140))

        do {
            _ = try await useCase.finalize()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? DiarySummaryError, .inferenceFailed())
        }
    }

    func test_finalize_resetsAccumulatedUtterancesForNextSession() async throws {
        let repository = MockDiarySummaryRepository()
        let useCase = DefaultSummarizeDiaryUseCase(diarySummaryRepository: repository)

        await useCase.addUtterance("첫 번째 세션 발화")
        _ = try await useCase.finalize()

        await useCase.addUtterance("두 번째 세션 발화")
        let result = try await useCase.finalize()

        XCTAssertEqual(result, "두 번째 세션 발화")
    }
}
