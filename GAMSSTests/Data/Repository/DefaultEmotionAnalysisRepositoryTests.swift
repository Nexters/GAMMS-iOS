//
//  DefaultEmotionAnalysisRepositoryTests.swift
//  GAMSS
//
//  Created by cchanmi on 7/24/26.
//

import XCTest
@testable import GAMSS

final class DefaultEmotionAnalysisRepositoryTests: XCTestCase {
    private struct Sample: Decodable {
        let text: String
        let expectedLabel: String

        enum CodingKeys: String, CodingKey {
            case text
            case expectedLabel = "expected_label"
        }
    }

    private func loadSamples() throws -> [Sample] {
        let url = Bundle(for: Self.self).url(forResource: "sample_sentences", withExtension: "json")!
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Sample].self, from: data)
    }

    func test_analyze_emptyText_throwsEmptyInput() async throws {
        let repository = try await DefaultEmotionAnalysisRepository.make()

        do {
            _ = try await repository.analyze(text: "   ")
            XCTFail("Expected emptyInput error")
        } catch {
            XCTAssertEqual(error as? EmotionAnalysisError, .emptyInput)
        }
    }

    // 모델 자체 정확도가 gold 라벨 대비 100%가 아니므로(약 44/60 수준),
    // 문장별 정확 일치 대신 전체 정확도가 기준치 이상인지만 확인한다.
    func test_analyze_sampleSentences_matchAndroidAccuracyLevel() async throws {
        let repository = try await DefaultEmotionAnalysisRepository.make()
        let samples = try loadSamples()

        var mismatches: [String] = []
        var correctCount = 0
        for sample in samples {
            let result = try await repository.analyze(text: sample.text)
            if result.emotion.rawValue == sample.expectedLabel {
                correctCount += 1
            } else {
                mismatches.append("'\(sample.text)' expected \(sample.expectedLabel) but got \(result.emotion.rawValue)")
            }
        }

        // 기준 정확도(44/60) 대비 크게 벗어나면 회귀로 판단한다.
        XCTAssertGreaterThanOrEqual(
            correctCount,
            40,
            "정확도가 기준치(44/60)에서 크게 벗어남: \(correctCount)/\(samples.count) — 불일치: \(mismatches)"
        )
    }
}
