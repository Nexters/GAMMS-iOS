//
//  EmotionTestViewModel.swift
//  GAMSS
//
//  Created by cchanmi on 7/25/26.
//

import Combine
import Foundation

@MainActor
final class EmotionTestViewModel: ObservableObject {
    private let analyzeEmotionUseCase: AnalyzeEmotionUseCase

    @Published private(set) var isLoading = false
    @Published private(set) var result: EmotionAnalysisResult?
    @Published var errorMessage: String?

    init(analyzeEmotionUseCase: AnalyzeEmotionUseCase) {
        self.analyzeEmotionUseCase = analyzeEmotionUseCase
    }

    func analyze(text: String) async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            result = try await analyzeEmotionUseCase.execute(text: text)
        } catch {
            result = nil
            errorMessage = error.localizedDescription
        }
    }
}
