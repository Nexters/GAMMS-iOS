//
//  GetTokenUsageUseCaseTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/18/26.
//

import XCTest
@testable import GAMSS

private final class MockMemberRepository: MemberRepository {
    var stubbedResult: Result<TokenUsage, Error> = .failure(SummaryError.inferenceFailed())
    private(set) var fetchTokenUsageCallCount = 0

    func deleteMember() async throws { fatalError("not used in this test") }
    func fetchMyProfile() async throws -> User { fatalError("not used in this test") }
    func updateNickname(_ nickname: String) async throws -> User { fatalError("not used in this test") }

    func fetchTokenUsage() async throws -> TokenUsage {
        fetchTokenUsageCallCount += 1
        return try stubbedResult.get()
    }
}

final class GetTokenUsageUseCaseTests: XCTestCase {
    func test_execute_returnsTokenUsageFromRepository() async throws {
        let repository = MockMemberRepository()
        let usage = TokenUsage(usedTokens: 12000, dailyLimit: 100000, exceeded: false)
        repository.stubbedResult = .success(usage)
        let useCase = GetTokenUsageUseCase(memberRepository: repository)

        let result = try await useCase.execute()

        XCTAssertEqual(result, usage)
        XCTAssertEqual(repository.fetchTokenUsageCallCount, 1)
    }

    func test_execute_propagatesRepositoryError() async {
        let repository = MockMemberRepository()
        repository.stubbedResult = .failure(SummaryError.inferenceFailed())
        let useCase = GetTokenUsageUseCase(memberRepository: repository)

        do {
            _ = try await useCase.execute()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? SummaryError, .inferenceFailed())
        }
    }
}
