//
//  EmotionAnalysisRepository.swift
//  GAMSS
//
//  Created by cchanmi on 7/24/26.
//

protocol EmotionAnalysisRepository {
    func analyze(text: String) async throws -> EmotionAnalysisResult
}
