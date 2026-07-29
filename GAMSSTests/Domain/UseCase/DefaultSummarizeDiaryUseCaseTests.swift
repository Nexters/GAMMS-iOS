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
    func test_execute_emptyText_returnsNilWithoutCallingRepository() async throws {
        let repository = MockDiarySummaryRepository()
        let useCase = DefaultSummarizeDiaryUseCase(diarySummaryRepository: repository)

        let result = try await useCase.execute(text: "   ")

        XCTAssertNil(result)
        XCTAssertNil(repository.receivedText)
    }

    func test_execute_shortText_returnsTrimmedTextWithoutCallingRepository() async throws {
        let repository = MockDiarySummaryRepository()
        let useCase = DefaultSummarizeDiaryUseCase(diarySummaryRepository: repository)

        let result = try await useCase.execute(text: "  오늘 억울한 일이 있었어  ")

        XCTAssertEqual(result, "오늘 억울한 일이 있었어")
        XCTAssertNil(repository.receivedText)
    }

    func test_execute_longText_returnsRepositoryResult() async throws {
        let repository = MockDiarySummaryRepository()
        repository.stubbedResult = .success("요약됨")
        let useCase = DefaultSummarizeDiaryUseCase(diarySummaryRepository: repository)
        let longText = String(repeating: "가", count: 50)

        let result = try await useCase.execute(text: longText)

        XCTAssertEqual(result, "요약됨")
        XCTAssertEqual(repository.receivedText, longText)
    }

    func test_execute_propagatesRepositoryError() async {
        let repository = MockDiarySummaryRepository()
        repository.stubbedResult = .failure(DiarySummaryError.inferenceFailed())
        let useCase = DefaultSummarizeDiaryUseCase(diarySummaryRepository: repository)
        let longText = String(repeating: "가", count: 50)

        do {
            _ = try await useCase.execute(text: longText)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? DiarySummaryError, .inferenceFailed())
        }
    }
}
