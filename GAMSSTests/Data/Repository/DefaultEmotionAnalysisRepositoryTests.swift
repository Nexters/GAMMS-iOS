//
//  DefaultEmotionAnalysisRepositoryTests.swift
//  GAMSS
//
//  Created by cchanmi on 7/24/26.
//

import XCTest
import Tokenizers
@testable import GAMSS

final class DefaultEmotionAnalysisRepositoryTests: XCTestCase {
    private struct Sample: Decodable {
        let text: String
        let expectedLabel: String
        let tokenIds: [Int]

        enum CodingKeys: String, CodingKey {
            case text
            case expectedLabel = "expected_label"
            case tokenIds = "token_ids"
        }
    }

    private func loadSamples() throws -> [Sample] {
        let url = Bundle(for: Self.self).url(forResource: "sample_sentences", withExtension: "json")!
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Sample].self, from: data)
    }

    // fixture의 token_ids는 이미 Python 쪽에서 truncation된 값이므로,
    // Swift raw encode 결과도 동일하게 잘라야 긴 문장도 비교가 맞는다.
    private static let maxLength = 128
    private static let sepTokenId = 3

    private static func pythonTruncated(_ ids: [Int]) -> [Int] {
        guard ids.count > maxLength else { return ids }
        return Array(ids.prefix(maxLength - 1)) + [sepTokenId]
    }

    func test_encode_sampleSentences_matchPythonTokenIds() async throws {
        let tokenizerFolder = Bundle.main.url(forResource: "tokenizer", withExtension: "json")!
            .deletingLastPathComponent()
        let tokenizer = try await AutoTokenizer.from(modelFolder: tokenizerFolder)
        let samples = try loadSamples()

        for sample in samples {
            let ids = Self.pythonTruncated(tokenizer.encode(text: sample.text))
            XCTAssertEqual(
                ids,
                sample.tokenIds,
                "Tokenization mismatch for '\(sample.text)': swift=\(ids) python=\(sample.tokenIds)"
            )
        }
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

    func test_analyze_sampleSentences_matchPythonValidationLabels() async throws {
        let repository = try await DefaultEmotionAnalysisRepository.make()
        let samples = try loadSamples()

        for sample in samples {
            let result = try await repository.analyze(text: sample.text)
            XCTAssertEqual(
                result.emotion.rawValue,
                sample.expectedLabel,
                "'\(sample.text)' expected \(sample.expectedLabel) but got \(result.emotion.rawValue)"
            )
        }
    }
}
