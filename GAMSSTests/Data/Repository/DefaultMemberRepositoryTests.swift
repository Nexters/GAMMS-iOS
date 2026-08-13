//
//  DefaultMemberRepositoryTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import XCTest
@testable import GAMSS

private final class MockNetworkRequesting: NetworkRequesting {
    var stubbedData: Data?
    var stubbedError: Error?
    private(set) var lastEndpoint: Endpoint?

    func request<T: Decodable & Sendable>(_ endpoint: Endpoint, responseType: T.Type) async throws -> T {
        lastEndpoint = endpoint
        if let stubbedError { throw stubbedError }
        guard let stubbedData else { fatalError("stubbedData not set") }
        return try JSONDecoder().decode(T.self, from: stubbedData)
    }
}

final class DefaultMemberRepositoryTests: XCTestCase {
    func test_fetchMyProfile_decodesResponseAndMapsToDomain() async throws {
        let network = MockNetworkRequesting()
        network.stubbedData = Data("""
        {"success":true,"data":{"id":1,"email":"test@example.com","name":"테스트","nickname":"햄스터"},"error":null}
        """.utf8)
        let repository = DefaultMemberRepository(networkManager: network, tokenStorage: .shared)

        let user = try await repository.fetchMyProfile()

        XCTAssertEqual(user.id, 1)
        XCTAssertEqual(user.nickname, "햄스터")
        XCTAssertEqual(network.lastEndpoint?.path, "/api/members/me")
        XCTAssertEqual(network.lastEndpoint?.method, .get)
    }

    /// 회귀 테스트: 닉네임을 아직 설정하지 않은 사용자의 실제 서버 응답 형태(name/nickname
    /// null, DTO에 없는 status/createdAt 필드 포함)로도 실패 없이 조회돼야 한다.
    func test_fetchMyProfile_serverReturnsNullNameAndNickname_decodesSuccessfullyWithNilValues() async throws {
        let network = MockNetworkRequesting()
        network.stubbedData = Data("""
        {"success":true,"data":{"id":3,"email":"a@example.com","name":null,"nickname":null,"status":"ACTIVE","createdAt":"2026-08-01T04:08:46.042194Z"},"error":null}
        """.utf8)
        let repository = DefaultMemberRepository(networkManager: network, tokenStorage: .shared)

        let user = try await repository.fetchMyProfile()

        XCTAssertEqual(user.id, 3)
        XCTAssertNil(user.name)
        XCTAssertNil(user.nickname)
    }

    func test_fetchMyProfile_propagatesNetworkError() async {
        let network = MockNetworkRequesting()
        network.stubbedError = SummaryError.inferenceFailed()
        let repository = DefaultMemberRepository(networkManager: network, tokenStorage: .shared)

        do {
            _ = try await repository.fetchMyProfile()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? SummaryError, .inferenceFailed())
        }
    }
}
