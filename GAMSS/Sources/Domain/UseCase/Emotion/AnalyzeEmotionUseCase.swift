//
//  AnalyzeEmotionUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 7/24/26.
//

protocol AnalyzeEmotionUseCase {
    func execute(text: String) async throws -> EmotionAnalysisResult
}
