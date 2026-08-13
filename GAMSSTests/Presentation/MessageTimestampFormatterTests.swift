//
//  MessageTimestampFormatterTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/12/26.
//

import XCTest
@testable import GAMSS

final class MessageTimestampFormatterTests: XCTestCase {
    private func makeDate(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.timeZone = TimeZone(identifier: "Asia/Seoul")
        components.year = 2026
        components.month = 8
        components.day = 7
        components.hour = hour
        components.minute = minute
        return Calendar(identifier: .gregorian).date(from: components)!
    }

    func test_string_afternoonTime_usesPMMarker() {
        XCTAssertEqual(MessageTimestampFormatter.string(from: makeDate(hour: 13, minute: 37)), "오후 1:37")
    }

    func test_string_morningTime_usesAMMarker() {
        XCTAssertEqual(MessageTimestampFormatter.string(from: makeDate(hour: 9, minute: 5)), "오전 9:05")
    }
}
