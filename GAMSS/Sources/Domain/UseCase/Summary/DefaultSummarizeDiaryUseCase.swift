//
//  DefaultSummarizeDiaryUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 7/29/26.
//

import Foundation

actor DefaultSummarizeDiaryUseCase: SummarizeDiaryUseCase {
    // 누적된 USER 발화가 이 미만이면 요약해도 원문과 큰 차이가 없어 의미가 없으므로,
    // 모델을 호출하지 않고 누적 원문을 그대로 사용한다.
    private static let minCharsForSummary = 140

    private let diarySummaryRepository: DiarySummaryRepository
    private var utterances: [String] = []

    init(diarySummaryRepository: DiarySummaryRepository) {
        self.diarySummaryRepository = diarySummaryRepository
    }

    func addUtterance(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        utterances.append(trimmed)
    }

    func finalize() async throws -> String? {
        let combined = utterances.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        utterances = []

        guard !combined.isEmpty else { return nil }
        guard combined.count >= Self.minCharsForSummary else { return combined }
        return try await diarySummaryRepository.summarize(text: combined)
    }
}
