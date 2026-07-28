//
//  DefaultAnalyzeEmotionUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 7/24/26.
//

final class DefaultAnalyzeEmotionUseCase: AnalyzeEmotionUseCase {
    private let emotionAnalysisRepository: EmotionAnalysisRepository

    init(emotionAnalysisRepository: EmotionAnalysisRepository) {
        self.emotionAnalysisRepository = emotionAnalysisRepository
    }

    func execute(text: String) async throws -> EmotionAnalysisResult {
        try await emotionAnalysisRepository.analyze(text: text)
    }
}
