//
//  EmotionCharacterTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import XCTest
@testable import GAMSS

final class EmotionCharacterTests: XCTestCase {
    func test_displayName_isKoreanForEveryCase() {
        XCTAssertEqual(EmotionCharacter.joy.displayName, "기쁨이")
        XCTAssertEqual(EmotionCharacter.sadness.displayName, "슬픔이")
        XCTAssertEqual(EmotionCharacter.anger.displayName, "분노")
        XCTAssertEqual(EmotionCharacter.anxiety.displayName, "불안")
        XCTAssertEqual(EmotionCharacter.prickly.displayName, "까칠이")
        XCTAssertEqual(EmotionCharacter.quirky.displayName, "엉뚱이")
    }

    func test_allCases_hasExactlySixCharacters() {
        XCTAssertEqual(EmotionCharacter.allCases.count, 6)
    }
}
