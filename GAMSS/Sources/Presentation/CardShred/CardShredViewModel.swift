//
//  CardShredViewModel.swift
//  GAMSS
//
//  Created by 이건준 on 8/21/26.
//

import Combine
import Foundation

enum CardShredMode: Hashable, Identifiable {
    case single(cardId: Int)
    case all

    var id: Self { self }
}

@MainActor
final class CardShredViewModel: ObservableObject {
    @Published private(set) var step = 0
    @Published private(set) var isSubmitting = false
    @Published var alertMessage: String?

    private let mode: CardShredMode
    private let deleteCardUseCase: DeleteCardUseCase?
    private let deleteAllCardUseCase: DeleteAllCardUseCase?
    private let requiredSteps = 4

    init(cardId: Int, deleteCardUseCase: DeleteCardUseCase) {
        self.mode = .single(cardId: cardId)
        self.deleteCardUseCase = deleteCardUseCase
        self.deleteAllCardUseCase = nil
    }

    init(deleteAllCardUseCase: DeleteAllCardUseCase) {
        self.mode = .all
        self.deleteCardUseCase = nil
        self.deleteAllCardUseCase = deleteAllCardUseCase
    }

    var isPowerOn: Bool {
        step > 0 && step < requiredSteps
    }

    var isShredEnabled: Bool {
        step >= requiredSteps
    }

    var progress: CGFloat {
        CGFloat(step) / CGFloat(requiredSteps)
    }

    func advance() {
        guard step < requiredSteps else { return }
        step += 1
    }

    @discardableResult
    func shred() async -> Bool {
        guard isShredEnabled, !isSubmitting else { return false }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            switch mode {
            case .single(let cardId):
                guard let deleteCardUseCase else { return false }
                try await deleteCardUseCase.execute(cardId: cardId)
            case .all:
                guard let deleteAllCardUseCase else { return false }
                try await deleteAllCardUseCase.execute()
            }
            return true
        } catch {
            alertMessage = "기록을 파쇄하지 못했어요"
            return false
        }
    }
}
