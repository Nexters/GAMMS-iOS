//
//  RiskLexiconDTOTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

import XCTest
@testable import GAMSS

final class RiskLexiconDTOTests: XCTestCase {
    func test_toDomain_sortsAgenciesByPriority() {
        let dto = RiskLexiconDTO(
            version: 2,
            terms: [RiskTermDTO(term: "자살", level: "CRITICAL")],
            safePhrases: ["자살예방"],
            agencies: [
                SupportAgencyDTO(id: "b", name: "B", description: "", phoneNumber: "222", url: nil, priority: 2),
                SupportAgencyDTO(id: "a", name: "A", description: "", phoneNumber: "111", url: nil, priority: 1),
            ]
        )

        let lexicon = dto.toDomain()

        XCTAssertEqual(lexicon.agencies.map(\.name), ["A", "B"])
        XCTAssertEqual(lexicon.version, 2)
    }

    func test_toDomain_unknownLevel_mapsToWarning() {
        let dto = RiskLexiconDTO(version: 1, terms: [RiskTermDTO(term: "자살", level: "UNKNOWN")], safePhrases: [], agencies: [])

        XCTAssertEqual(dto.toDomain().terms.first?.level, .warning)
    }

    func test_toDomain_blankTerm_isDropped() {
        let dto = RiskLexiconDTO(version: 1, terms: [RiskTermDTO(term: "", level: "CRITICAL")], safePhrases: [], agencies: [])

        XCTAssertTrue(dto.toDomain().terms.isEmpty)
    }

    func test_decode_fromJSON_producesExpectedFields() throws {
        let json = """
        { "version": 1, "terms": [{"term": "자살", "level": "CRITICAL"}], "safePhrases": [], "agencies": [] }
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode(RiskLexiconDTO.self, from: json)

        XCTAssertEqual(dto.version, 1)
        XCTAssertEqual(dto.terms.first?.term, "자살")
    }
}
