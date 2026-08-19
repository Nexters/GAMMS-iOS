//
//  DefaultFetchMyProfileUseCaseTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import XCTest
@testable import GAMSS

private final class MockMemberRepository: MemberRepository {
    var stubbedResult: Result<User, Error> = .failure(SummaryError.inferenceFailed())
    private(set) var fetchMyProfileCallCount = 0

    func deleteMember() async throws {}

    func fetchMyProfile() async throws -> User {
        fetchMyProfileCallCount += 1
        return try stubbedResult.get()
    }

    func updateNickname(_ nickname: String) async throws -> User {
        fatalError("not used in this test")
    }

    func fetchTokenUsage() async throws -> TokenUsage {
        fatalError("not used in this test")
    }
}

final class DefaultFetchMyProfileUseCaseTests: XCTestCase {
    func test_execute_returnsUserFromRepository() async throws {
        let repository = MockMemberRepository()
        let user = User(id: 1, email: "test@example.com", name: "테스트", nickname: "햄스터")
        repository.stubbedResult = .success(user)
        let useCase = DefaultFetchMyProfileUseCase(memberRepository: repository)

        let result = try await useCase.execute()

        XCTAssertEqual(result.nickname, "햄스터")
        XCTAssertEqual(repository.fetchMyProfileCallCount, 1)
    }

    func test_execute_propagatesRepositoryError() async {
        let repository = MockMemberRepository()
        repository.stubbedResult = .failure(SummaryError.inferenceFailed())
        let useCase = DefaultFetchMyProfileUseCase(memberRepository: repository)

        do {
            _ = try await useCase.execute()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? SummaryError, .inferenceFailed())
        }
    }
}
