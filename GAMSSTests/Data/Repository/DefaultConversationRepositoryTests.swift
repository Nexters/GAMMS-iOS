//
//  DefaultConversationRepositoryTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import XCTest
@testable import GAMSS

/// 실제 네트워크를 타지 않고, 서버 응답 형태의 JSON을 그대로 디코딩시켜 매핑 로직을 검증한다.
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

final class DefaultConversationRepositoryTests: XCTestCase {
    func test_sendMessage_decodesResponseAndMapsToDomain() async throws {
        let network = MockNetworkRequesting()
        network.stubbedData = Data("""
        {"success":true,"data":{"message":{"id":1,"conversationId":10,"senderType":"USER","emotionType":null,"content":"안녕","repliesToMessageId":null,"rootMessageId":null,"createdAt":"2026-08-07T00:00:00Z"},"commentStatus":"DONE","comments":[{"id":2,"conversationId":10,"senderType":"CHARACTER","emotionType":"JOY","content":"반가워","repliesToMessageId":1,"rootMessageId":1,"createdAt":"2026-08-07T00:00:01Z"}]},"error":null}
        """.utf8)
        let repository = DefaultConversationRepository(networkManager: network)

        let result = try await repository.sendMessage(conversationId: nil, content: "안녕", repliesToMessageId: nil, contextSummary: nil)

        XCTAssertEqual(result.message.content, "안녕")
        XCTAssertEqual(result.message.sender, .user)
        XCTAssertEqual(result.commentStatus, .done)
        XCTAssertEqual(result.comments.count, 1)
        XCTAssertEqual(result.comments.first?.sender, .character(.joy))
        XCTAssertEqual(network.lastEndpoint?.path, "/api/conversations/messages")
        XCTAssertEqual(network.lastEndpoint?.method, .post)
    }

    func test_getMessages_decodesResponseAndExcludesUnresolvableSenders() async throws {
        let network = MockNetworkRequesting()
        network.stubbedData = Data("""
        {"success":true,"data":[{"id":1,"conversationId":10,"senderType":"USER","emotionType":null,"content":"안녕","repliesToMessageId":null,"rootMessageId":null,"createdAt":"2026-08-07T00:00:00Z"},{"id":2,"conversationId":10,"senderType":"CHARACTER","emotionType":"UNKNOWN","content":"???","repliesToMessageId":null,"rootMessageId":null,"createdAt":"2026-08-07T00:00:01Z"}],"error":null}
        """.utf8)
        let repository = DefaultConversationRepository(networkManager: network)

        let result = try await repository.getMessages(conversationId: 10)

        XCTAssertEqual(result.count, 1, "senderType을 알 수 없는 메시지는 목록에서 제외되어야 함")
        XCTAssertEqual(result.first?.content, "안녕")
        XCTAssertEqual(network.lastEndpoint?.path, "/api/conversations/10/messages")
        XCTAssertEqual(network.lastEndpoint?.method, .get)
    }

    func test_getIncompleteConversations_decodesResponseAndExcludesInvalidCreatedAt() async throws {
        let network = MockNetworkRequesting()
        network.stubbedData = Data("""
        {"success":true,"data":[{"id":1,"title":"첫 대화","status":"ACTIVE","createdAt":"2026-08-07T00:00:00Z","updatedAt":"2026-08-07T00:00:00Z"},{"id":2,"title":"잘못된 대화","status":"ACTIVE","createdAt":"이상한값","updatedAt":"이상한값"}],"error":null}
        """.utf8)
        let repository = DefaultConversationRepository(networkManager: network)

        let result = try await repository.getIncompleteConversations()

        XCTAssertEqual(result.count, 1, "createdAt 파싱에 실패한 대화방은 목록에서 제외되어야 함")
        XCTAssertEqual(result.first?.id, 1)
        XCTAssertEqual(network.lastEndpoint?.path, "/api/conversations/incomplete")
        XCTAssertEqual(network.lastEndpoint?.method, .get)
    }
}
