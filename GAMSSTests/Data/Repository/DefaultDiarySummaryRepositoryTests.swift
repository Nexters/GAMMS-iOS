//
//  DefaultDiarySummaryRepositoryTests.swift
//  GAMSS
//
//  Created by cchanmi on 7/31/26.
//

import XCTest
@testable import GAMSS

final class DefaultDiarySummaryRepositoryTests: XCTestCase {
    private func loadDiaries() throws -> [String] {
        let url = Bundle(for: Self.self).url(forResource: "diary_samples", withExtension: "json")!
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([String].self, from: data)
    }

    // 모델 품질은 사람이 로그를 보고 판단한다 (감정 분석 정확도 테스트와 동일한 철학).
    // 여기서는 "비어있지 않음"과 "크래시 없음"만 assert하고, 입력/출력/소요시간을 로그로 남긴다.
    func test_summarize_sampleDiaries_producesNonEmptySummaryWithoutCrashing() async throws {
        let repository = try await DefaultDiarySummaryRepository.make()
        let diaries = try loadDiaries()

        for (index, diary) in diaries.enumerated() {
            let started = Date()
            let summary = try await repository.summarize(text: diary)
            let elapsedMs = Int(Date().timeIntervalSince(started) * 1000)

            XCTAssertFalse(summary.isEmpty, "요약 결과가 비어있음: 입력 '\(diary)'")
            Log.info("SUMMARY_EVAL|\(index)|\(elapsedMs)ms|입력=\(diary)")
            Log.info("SUMMARY_EVAL|\(index)|요약=\(summary)")
        }
    }

    // 게이팅 확인: 짧은 문장은 UseCase가 원문 그대로 반환하고(모델 호출 없음),
    // 긴 일기는 Repository를 거쳐 실제로 요약되어야 한다.
    func test_gating_shortTextReturnsAsIs_longTextIsSummarized() async throws {
        let repository = try await DefaultDiarySummaryRepository.make()
        let useCase = DefaultSummarizeDiaryUseCase(diarySummaryRepository: repository)
        let diaries = try loadDiaries()

        let short = try await useCase.execute(text: "오늘 억울한 일이 있었어")
        XCTAssertEqual(short, "오늘 억울한 일이 있었어")

        let long = try await useCase.execute(text: diaries[0])
        XCTAssertNotNil(long)
        XCTAssertNotEqual(long, diaries[0])
    }
}
