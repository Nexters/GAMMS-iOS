//
//  DailyEmotion.swift
//  GAMSS
//
//  Created by 이건준 on 8/18/26.
//

import Foundation

struct DailyEmotion: Identifiable, Equatable {
    let date: Date
    let emotions: [Emotion]

    var id: Date { date }
}
