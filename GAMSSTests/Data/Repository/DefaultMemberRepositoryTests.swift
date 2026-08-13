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
