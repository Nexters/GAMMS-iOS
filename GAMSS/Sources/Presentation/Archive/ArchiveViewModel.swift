//
//  ArchiveViewModel.swift
//  GAMSS
//
//  Created by 이건준 on 8/18/26.
//

import Combine

final class ArchiveViewModel: ObservableObject {
    @Published var emotions: [Emotion] = [
        .angry,
        .happy,
        .sad,
        .heartache,
        .anxious,
        .embarrassed
    ]
}

extension Emotion {
    var trashImageNamed: String {
        switch self {
        case .angry:
            return "angry_trash"
        case .happy:
            return "happy_trash"
        case .anxious:
            return "anxious_trash"
        case .embarrassed:
            return "embarrassed_trash"
        case .sad:
            return "sad_trash"
        case .heartache:
            return "heartache_trash"
        }
    }
}
