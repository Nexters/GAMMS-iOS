//
//  ConversationPage.swift
//  GAMSS
//
//  Created by 이건준 on 8/31/26.
//

import Foundation

struct ConversationPage {
    let items: [ConversationSummary]
    let page: Int
    let size: Int
    let totalPages: Int

    var hasNextPage: Bool {
        page + 1 < totalPages
    }
}
