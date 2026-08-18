//
//  ArchiveDetailViewModel.swift
//  GAMSS
//
//  Created by 이건준 on 8/18/26.
//

import Combine
import Foundation

@MainActor
final class ArchiveDetailViewModel: ObservableObject {
    @Published var selectedMonth: Date
    @Published private(set) var notes: [DropNote] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let fetchMonthlyCardsUseCase: FetchMonthlyCardsUseCase

    init(
        fetchMonthlyCardsUseCase: FetchMonthlyCardsUseCase,
        selectedMonth: Date = Date.now
    ) {
        self.fetchMonthlyCardsUseCase = fetchMonthlyCardsUseCase
        self.selectedMonth = selectedMonth
    }

    var dropCount: Int { notes.count }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            notes = try await fetchMonthlyCardsUseCase.execute(yearMonth: selectedMonth).map { _ in
                DropNote(id: 0, imageName: "cardFoldStepTwo")
            }
        } catch {
            notes = []
            errorMessage = "노트 데이터를 불러오지 못했어요"
        }
    }

    func selectMonth(_ month: Date) async {
        selectedMonth = month
        await load()
    }

    func clearNotes() {
        notes = []
    }
}
