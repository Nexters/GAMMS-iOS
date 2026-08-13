//
//  EmotionCharacterServerKeyMappingTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import XCTest
@testable import GAMSS

final class EmotionCharacterServerKeyMappingTests: XCTestCase {
    func test_character_forKnownServerKeys_returnsExpectedCharacter() {
        let cases: [(String, EmotionCharacter)] = [
            ("JOY", .joy), ("ANGER", .anger), ("ANXIETY", .anxiety),
            ("GRUMPY", .prickly), ("SADNESS", .sadness), ("QUIRKY", .quirky),
        ]
        for (serverKey, expected) in cases {
            XCTAssertEqual(EmotionCharacterServerKeyMapping.character(forServerKey: serverKey), expected, "서버 키 \(serverKey)")
        }
    }

    func test_character_forUnknownServerKey_returnsNil() {
        XCTAssertNil(EmotionCharacterServerKeyMapping.character(forServerKey: "UNKNOWN"))
    }

    func test_serverKey_forEachCharacter_roundTripsBackToSameCharacter() {
        for character in EmotionCharacter.allCases {
            let key = EmotionCharacterServerKeyMapping.serverKey(for: character)
            XCTAssertEqual(EmotionCharacterServerKeyMapping.character(forServerKey: key), character, "캐릭터 \(character)")
        }
    }
}
