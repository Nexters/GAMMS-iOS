//
//  ConversationSummaryDTOTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import XCTest
@testable import GAMSS

final class ConversationSummaryDTOTests: XCTestCase {
    private func makeDTO(createdAt: String) -> ConversationSummaryDTO {
        ConversationSummaryDTO(id: 1, title: "제목", status: "ACTIVE", createdAt: createdAt, updatedAt: createdAt)
    }

    func test_toDomain_parsesCreatedAtAsISO8601Date() throws {
        let dto = makeDTO(createdAt: "2026-08-07T00:00:00Z")

        let createdAt = try XCTUnwrap(dto.toDomain()?.createdAt)

        XCTAssertEqual(createdAt, ISO8601DateFormatter().date(from: "2026-08-07T00:00:00Z"))
    }

    func test_toDomain_fractionalSecondsCreatedAt_parsesSuccessfullyIgnoringFraction() throws {
        let dto = makeDTO(createdAt: "2026-08-07T00:00:00.500Z")

        let createdAt = try XCTUnwrap(dto.toDomain()?.createdAt)

        XCTAssertEqual(createdAt, ISO8601DateFormatter().date(from: "2026-08-07T00:00:00Z"))
    }

    func test_toDomain_invalidCreatedAt_returnsNil() {
        let dto = makeDTO(createdAt: "이상한값")

        XCTAssertNil(dto.toDomain(), "createdAt 파싱에 실패하면 잘못된 시간으로 표시하는 대신 목록에서 제외되어야 함")
    }

    func test_toDomain_mapsIdTitleAndStatus() throws {
        let dto = makeDTO(createdAt: "2026-08-07T00:00:00Z")

        let summary = try XCTUnwrap(dto.toDomain())

        XCTAssertEqual(summary.id, 1)
        XCTAssertEqual(summary.title, "제목")
        XCTAssertEqual(summary.status, "ACTIVE")
    }
}
