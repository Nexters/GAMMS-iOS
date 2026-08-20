//
//  RiskLexiconCacheTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

import XCTest
@testable import GAMSS

final class RiskLexiconCacheTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var cache: RiskLexiconCache!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        cache = RiskLexiconCache(userDefaults: userDefaults)
    }

    func test_read_withNoWrite_returnsNil() {
        XCTAssertNil(cache.read())
    }

    func test_isStale_withNoWrite_isTrue() {
        XCTAssertTrue(cache.isStale)
    }

    func test_write_thenRead_returnsSameDTO() {
        let dto = RiskLexiconDTO(version: 3, terms: [], safePhrases: [], agencies: [])

        cache.write(dto)

        XCTAssertEqual(cache.read()?.version, 3)
    }

    func test_write_thenIsStale_isFalse() {
        cache.write(RiskLexiconDTO(version: 1, terms: [], safePhrases: [], agencies: []))

        XCTAssertFalse(cache.isStale)
    }
}
