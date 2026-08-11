//
//  MainTabTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/10/26.
//

import XCTest
@testable import GAMSS

final class MainTabTests: XCTestCase {
    func test_title_returnsKoreanLabelForEachTab() {
        XCTAssertEqual(MainTab.archive.title, "보관함")
        XCTAssertEqual(MainTab.home.title, "홈")
        XCTAssertEqual(MainTab.chat.title, "대화")
    }

    func test_iconName_returnsAssetNameForEachTab() {
        XCTAssertEqual(MainTab.archive.iconName, "tabIconArchive")
        XCTAssertEqual(MainTab.home.iconName, "tabIconHome")
        XCTAssertEqual(MainTab.chat.iconName, "tabIconChat")
    }

    func test_allCases_containsThreeTabsInOrder() {
        XCTAssertEqual(MainTab.allCases, [.archive, .home, .chat])
    }
}
