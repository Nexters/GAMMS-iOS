//
//  CardShredViewModel.swift
//  GAMSS
//
//  Created by 이건준 on 8/21/26.
//

import Combine
import Foundation

@MainActor
final class CardShredViewModel: ObservableObject {
    @Published private(set) var step = 0
    @Published private(set) var isSubmitting = false
    @Published var alertMessage: String?

    private let cardId: Int
    private let deleteCardUseCase: DeleteCardUseCase
    private let requiredSteps = 4

    init(cardId: Int, deleteCardUseCase: DeleteCardUseCase) {
        self.cardId = cardId
        self.deleteCardUseCase = deleteCardUseCase
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
            try await deleteCardUseCase.execute(cardId: cardId)
            return true
        } catch {
            alertMessage = "기록을 파쇄하지 못했어요"
            return false
        }
    }
}
