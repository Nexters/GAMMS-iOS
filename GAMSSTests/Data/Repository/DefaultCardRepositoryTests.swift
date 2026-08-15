//
//  DefaultCardRepositoryTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/15/26.
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

final class DefaultCardRepositoryTests: XCTestCase {
    func test_createCard_decodesResponseAndMapsToDomain() async throws {
        let network = MockNetworkRequesting()
        network.stubbedData = Data("""
        {"success":true,"data":{"id":1,"conversationId":10,"emotion":"ANGER","emotionLabel":"분노","summary":"오늘 비가 와서 짜증나고 찝찝하다","message":"얘 오늘 건들면 안 됨.","date":"2026-07-23"},"error":null}
        """.utf8)
        let repository = DefaultCardRepository(networkManager: network)

        let card = try await repository.createCard(conversationId: 10, emotion: .anger, summary: "오늘 비가 와서 짜증나고 찝찝하다")

        XCTAssertEqual(card.id, 1)
        XCTAssertEqual(card.conversationId, 10)
        XCTAssertEqual(card.emotion, .anger)
        XCTAssertEqual(card.message, "얘 오늘 건들면 안 됨.")
        XCTAssertEqual(network.lastEndpoint?.path, "/api/cards")
        XCTAssertEqual(network.lastEndpoint?.method, .post)
    }

    func test_createCard_mapsEmotionToServerKeyInRequest() async throws {
        let network = MockNetworkRequesting()
        network.stubbedData = Data("""
        {"success":true,"data":{"id":1,"conversationId":10,"emotion":"ANGER","emotionLabel":"분노","summary":"요약","message":"메시지","date":"2026-07-23"},"error":null}
        """.utf8)
        let repository = DefaultCardRepository(networkManager: network)

        _ = try await repository.createCard(conversationId: 10, emotion: .anger, summary: "요약")

        guard case let .createCard(request)? = network.lastEndpoint as? CardEndpoint else {
            XCTFail("createCard 엔드포인트가 호출되어야 함")
            return
        }
        XCTAssertEqual(request.emotion, "ANGER")
    }

    func test_createCard_withNilEmotion_sendsNilInRequest() async throws {
        let network = MockNetworkRequesting()
        network.stubbedData = Data("""
        {"success":true,"data":{"id":1,"conversationId":10,"emotion":null,"emotionLabel":null,"summary":"요약","message":"메시지","date":"2026-07-23"},"error":null}
        """.utf8)
        let repository = DefaultCardRepository(networkManager: network)

        let card = try await repository.createCard(conversationId: 10, emotion: nil, summary: "요약")

        guard case let .createCard(request)? = network.lastEndpoint as? CardEndpoint else {
            XCTFail("createCard 엔드포인트가 호출되어야 함")
            return
        }
        XCTAssertNil(request.emotion)
        XCTAssertNil(card.emotion)
    }
}
