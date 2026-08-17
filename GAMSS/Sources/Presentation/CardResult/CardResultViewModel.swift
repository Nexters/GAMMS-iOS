//
//  CardResultViewModel.swift
//  GAMSS
//
//  Created by cchanmi on 8/16/26.
//

import Combine
import Foundation

@MainActor
final class CardResultViewModel: ObservableObject {
    enum FoldStage: Equatable {
        case unfolded
        case foldedOnce
        case foldedTwice
        case readyToDiscard

        var next: FoldStage? {
            switch self {
            case .unfolded: .foldedOnce
            case .foldedOnce: .foldedTwice
            case .foldedTwice: .readyToDiscard
            case .readyToDiscard: nil
            }
        }
    }

    @Published private(set) var stage: FoldStage = .unfolded
    @Published private(set) var dragOffset: CGFloat = 0

    static let discardThreshold: CGFloat = 120
    static let fadeDistance: CGFloat = 240

    func advanceStage() {
        guard let next = stage.next else { return }
        stage = next
    }

    func updateDrag(translationHeight: CGFloat) {
        dragOffset = max(0, translationHeight)
    }

    func resetDrag() {
        dragOffset = 0
    }

    static func shouldDiscard(dragOffset: CGFloat) -> Bool {
        dragOffset > discardThreshold
    }

    static func opacity(forDragOffset dragOffset: CGFloat) -> Double {
        let progress = min(max(dragOffset / fadeDistance, 0), 1)
        return 1.0 - progress * 0.7
    }
}
