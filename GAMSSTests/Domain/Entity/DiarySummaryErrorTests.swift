//
//  DiarySummaryErrorTests.swift
//  GAMSS
//
//  Created by cchanmi on 7/29/26.
//

import XCTest
@testable import GAMSS

final class DiarySummaryErrorTests: XCTestCase {
    func test_equality_ignoresUnderlyingError() {
        struct DummyError: Error {}

        XCTAssertEqual(
            DiarySummaryError.modelLoadFailed(underlying: DummyError()),
            DiarySummaryError.modelLoadFailed(underlying: nil)
        )
        XCTAssertEqual(DiarySummaryError.inferenceFailed(), DiarySummaryError.inferenceFailed())
        XCTAssertNotEqual(DiarySummaryError.modelLoadFailed(), DiarySummaryError.inferenceFailed())
    }

    func test_errorDescription_isKorean() {
        XCTAssertEqual(DiarySummaryError.modelLoadFailed().errorDescription, "요약 모델을 불러오지 못했어요.")
        XCTAssertEqual(DiarySummaryError.inferenceFailed().errorDescription, "요약을 생성하지 못했어요.")
    }
}
