//
//  DefaultSummaryRepositoryTests.swift
//  GAMSS
//

import XCTest
@testable import GAMSS

final class DefaultSummaryRepositoryTests: XCTestCase {
    private func loadDiaries() throws -> [String] {
        let url = Bundle(for: Self.self).url(forResource: "diary_samples", withExtension: "json")!
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([String].self, from: data)
    }

    // 모델 품질은 사람이 로그를 보고 판단한다. 여기서는 "비어있지 않음"과 "크래시 없음"만 assert하고,
    // 입력/출력/소요시간을 로그로 남긴다.
    func test_summarize_sampleTexts_producesNonEmptySummaryWithoutCrashing() async throws {
        let repository = try await DefaultSummaryRepository.make()
        let samples = try loadDiaries()

        for (index, sample) in samples.enumerated() {
            let started = Date()
            let summary = try await repository.summarize(text: sample)
            let elapsedMs = Int(Date().timeIntervalSince(started) * 1000)

            XCTAssertFalse(summary.isEmpty, "요약 결과가 비어있음: 입력 '\(sample)'")
            Log.info("SUMMARY_EVAL|\(index)|\(elapsedMs)ms|입력=\(sample)")
            Log.info("SUMMARY_EVAL|\(index)|요약=\(summary)")
        }
    }

    func test_countTokens_returnsPositiveCountForNonEmptyText() async throws {
        let repository = try await DefaultSummaryRepository.make()
        let count = try await repository.countTokens(text: "오늘 하루도 고생했어")
        XCTAssertGreaterThan(count, 0)
    }

    func test_countTokens_longerTextHasMoreTokensThanShorterText() async throws {
        let repository = try await DefaultSummaryRepository.make()
        let short = try await repository.countTokens(text: "안녕")
        let long = try await repository.countTokens(text: String(repeating: "안녕하세요 오늘 날씨가 좋네요 ", count: 20))
        XCTAssertGreaterThan(long, short)
    }
}
