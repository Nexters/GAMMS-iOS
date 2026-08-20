//
//  RiskDetectionTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

import XCTest
@testable import GAMSS

final class RiskDetectionTests: XCTestCase {
    func test_shouldBlock_onlyTrueForCritical() {
        XCTAssertTrue(RiskDetection(level: .critical, agencies: []).shouldBlock)
        XCTAssertFalse(RiskDetection(level: .warning, agencies: []).shouldBlock)
        XCTAssertFalse(RiskDetection(level: .none, agencies: []).shouldBlock)
    }

    func test_none_isEmptyDetection() {
        XCTAssertEqual(RiskDetection.none, RiskDetection(level: .none, agencies: []))
    }
}
