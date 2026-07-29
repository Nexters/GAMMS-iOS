//
//  DefaultSummarizeDiaryUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 7/29/26.
//

import Foundation

final class DefaultSummarizeDiaryUseCase: SummarizeDiaryUseCase {
    // 학습 분포(긴 문서)를 벗어난 짧은 캐주얼 입력은 모델에서 반복/할루시네이션을 유발하므로
    // 이 미만이면 모델을 호출하지 않고 원문을 그대로 쓴다.
    private static let minCharsForSummary = 50

    private let diarySummaryRepository: DiarySummaryRepository

    init(diarySummaryRepository: DiarySummaryRepository) {
        self.diarySummaryRepository = diarySummaryRepository
    }

    func execute(text: String) async throws -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard trimmed.count >= Self.minCharsForSummary else { return trimmed }
        return try await diarySummaryRepository.summarize(text: trimmed)
    }
}
