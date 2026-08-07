//
//  SummaryErrorTests.swift
//  GAMSS
//

import XCTest
@testable import GAMSS

final class SummaryErrorTests: XCTestCase {
    func test_equality_ignoresUnderlyingError() {
        struct DummyError: Error {}

        XCTAssertEqual(
            SummaryError.modelLoadFailed(underlying: DummyError()),
            SummaryError.modelLoadFailed(underlying: nil)
        )
        XCTAssertEqual(SummaryError.inferenceFailed(), SummaryError.inferenceFailed())
        XCTAssertNotEqual(SummaryError.modelLoadFailed(), SummaryError.inferenceFailed())
    }

    func test_errorDescription_isKorean() {
        XCTAssertEqual(SummaryError.modelLoadFailed().errorDescription, "요약 모델을 불러오지 못했어요.")
        XCTAssertEqual(SummaryError.inferenceFailed().errorDescription, "요약을 생성하지 못했어요.")
    }
}
