//
//  DailyEmotion.swift
//  GAMSS
//
//  Created by 이건준 on 8/18/26.
//

import Foundation

struct DailyEmotion: Identifiable, Equatable {
    let id: Int
    let conversationId: Int
    let date: Date
    let emotion: Emotion?
}
