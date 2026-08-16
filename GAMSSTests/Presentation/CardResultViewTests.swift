//
//  CardResultViewTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/16/26.
//

import XCTest
@testable import GAMSS

final class CardResultViewTests: XCTestCase {
    func test_foldStage_next_advancesThroughEachStageInOrder() {
        XCTAssertEqual(CardResultView.FoldStage.unfolded.next, .foldedOnce)
        XCTAssertEqual(CardResultView.FoldStage.foldedOnce.next, .foldedTwice)
        XCTAssertEqual(CardResultView.FoldStage.foldedTwice.next, .readyToDiscard)
    }

    func test_foldStage_next_readyToDiscard_returnsNil() {
        XCTAssertNil(CardResultView.FoldStage.readyToDiscard.next)
    }

    func test_shouldDiscard_belowThreshold_returnsFalse() {
        XCTAssertFalse(CardResultView.shouldDiscard(dragOffset: 0))
        XCTAssertFalse(CardResultView.shouldDiscard(dragOffset: 119))
    }

    func test_shouldDiscard_aboveThreshold_returnsTrue() {
        XCTAssertTrue(CardResultView.shouldDiscard(dragOffset: 121))
    }

    func test_opacity_noOffset_isFullyOpaque() {
        XCTAssertEqual(CardResultView.opacity(forDragOffset: 0), 1.0)
    }

    func test_opacity_atDiscardThreshold_isNotYetFullyFaded() {
        XCTAssertEqual(CardResultView.opacity(forDragOffset: 120), 0.65, accuracy: 0.0001)
    }

    func test_opacity_atFadeDistance_isMinimumOpacity() {
        XCTAssertEqual(CardResultView.opacity(forDragOffset: 240), 0.3, accuracy: 0.0001)
    }

    func test_opacity_beyondFadeDistance_staysClampedAtMinimum() {
        XCTAssertEqual(CardResultView.opacity(forDragOffset: 500), 0.3, accuracy: 0.0001)
    }

    func test_opacity_negativeOffset_staysFullyOpaque() {
        XCTAssertEqual(CardResultView.opacity(forDragOffset: -50), 1.0)
    }
}
