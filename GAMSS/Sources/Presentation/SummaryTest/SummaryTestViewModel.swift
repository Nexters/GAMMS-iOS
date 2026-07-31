//
//  SummaryTestViewModel.swift
//  GAMSS
//
//  Created by cchanmi on 7/31/26.
//

import Combine
import Foundation

@MainActor
final class SummaryTestViewModel: ObservableObject {
    private let summarizeDiaryUseCase: SummarizeDiaryUseCase

    @Published private(set) var utterances: [String] = []
    @Published private(set) var isLoading = false
    @Published private(set) var result: String?
    @Published var errorMessage: String?

    init(summarizeDiaryUseCase: SummarizeDiaryUseCase) {
        self.summarizeDiaryUseCase = summarizeDiaryUseCase
    }

    func addUtterance(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        await summarizeDiaryUseCase.addUtterance(trimmed)
        utterances.append(trimmed)
    }

    func finalizeSession() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            result = try await summarizeDiaryUseCase.finalize()
        } catch {
            result = nil
            errorMessage = error.localizedDescription
        }
        utterances = []
    }
}
