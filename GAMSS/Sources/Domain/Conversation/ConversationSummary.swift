//
//  ConversationSummary.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

import Foundation

struct ConversationSummary: Identifiable, Hashable {
    let id: Int
    let title: String?
    let createdAt: Date
}
