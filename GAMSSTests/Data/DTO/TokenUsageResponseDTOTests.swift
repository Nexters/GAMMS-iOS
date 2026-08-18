//
//  TokenUsageResponseDTOTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/18/26.
//

import XCTest
@testable import GAMSS

final class TokenUsageResponseDTOTests: XCTestCase {
    func test_toDomain_mapsAllFields() {
        let dto = TokenUsageResponseDTO(usedTokens: 12000, dailyLimit: 100000, exceeded: false)

        let usage = dto.toDomain()

        XCTAssertEqual(usage, TokenUsage(usedTokens: 12000, dailyLimit: 100000, exceeded: false))
    }

    func test_decode_fromServerShapedJSON_succeeds() throws {
        let json = """
        {"usedTokens":12000,"dailyLimit":100000,"exceeded":false}
        """
        let dto = try JSONDecoder().decode(TokenUsageResponseDTO.self, from: Data(json.utf8))

        XCTAssertEqual(dto.toDomain(), TokenUsage(usedTokens: 12000, dailyLimit: 100000, exceeded: false))
    }

    func test_decode_exceededTrue_succeeds() throws {
        let json = """
        {"usedTokens":100000,"dailyLimit":100000,"exceeded":true}
        """
        let dto = try JSONDecoder().decode(TokenUsageResponseDTO.self, from: Data(json.utf8))

        XCTAssertTrue(dto.toDomain().exceeded)
    }
}
