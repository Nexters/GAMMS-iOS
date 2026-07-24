//
//  EmotionTests.swift
//  GAMSS
//
//  Created by cchanmi on 7/24/26.
//

import XCTest
@testable import GAMSS

final class EmotionTests: XCTestCase {
    func test_orderedByModelIndex_hasSixEmotionsInModelOutputOrder() {
        XCTAssertEqual(Emotion.orderedByModelIndex.count, 6)
        XCTAssertEqual(Set(Emotion.orderedByModelIndex), Set(Emotion.allCases))
    }

    func test_analysisResult_storesEmotionAndConfidence() {
        let result = EmotionAnalysisResult(emotion: .happy, confidence: 0.87)

        XCTAssertEqual(result.emotion, .happy)
        XCTAssertEqual(result.confidence, 0.87, accuracy: 0.0001)
    }
}
