//
//  Card.swift
//  GAMSS
//
//  Created by cchanmi on 8/15/26.
//

import Foundation

struct Card: Identifiable, Equatable {
    let id: Int
    let conversationId: Int
    let emotion: EmotionCharacter?
    let summary: String
    let message: String
    let date: Date
}
