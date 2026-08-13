//
//  ISO8601FlexibleParserTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import XCTest
@testable import GAMSS

final class ISO8601FlexibleParserTests: XCTestCase {
    func test_date_validISO8601_parsesSuccessfully() {
        let result = ISO8601FlexibleParser.date(from: "2026-08-07T00:00:00Z")

        XCTAssertEqual(result, ISO8601DateFormatter().date(from: "2026-08-07T00:00:00Z"))
    }

    func test_date_fractionalSeconds_stripsAndParsesSuccessfully() {
        let result = ISO8601FlexibleParser.date(from: "2026-08-07T00:00:00.500Z")

        XCTAssertEqual(result, ISO8601DateFormatter().date(from: "2026-08-07T00:00:00Z"))
    }

    func test_date_invalidFormat_returnsNil() {
        XCTAssertNil(ISO8601FlexibleParser.date(from: "이상한값"))
    }
}
