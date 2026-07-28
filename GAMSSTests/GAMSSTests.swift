//
//  GAMSSTests.swift
//  GAMSS
//
//  Created by cchanmi on 7/24/26.
//

import XCTest
@testable import GAMSS

final class GAMSSTests: XCTestCase {
    func test_testTargetCanAccessHostAppModule() {
        XCTAssertFalse(Environment.bundleID.isEmpty)
    }
}
