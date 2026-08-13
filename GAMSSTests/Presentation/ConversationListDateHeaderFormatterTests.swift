//
//  ConversationListDateHeaderFormatterTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import XCTest
@testable import GAMSS

final class ConversationListDateHeaderFormatterTests: XCTestCase {
    func test_string_formatsAsTwoDigitYearMonthDay() {
        var components = DateComponents()
        components.timeZone = TimeZone(identifier: "Asia/Seoul")
        components.year = 2026
        components.month = 8
        components.day = 13
        let date = Calendar(identifier: .gregorian).date(from: components)!

        XCTAssertEqual(ConversationListDateHeaderFormatter.string(from: date), "26.08.13")
    }
}
