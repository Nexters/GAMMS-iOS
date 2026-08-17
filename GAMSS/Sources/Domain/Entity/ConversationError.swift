//
//  ConversationError.swift
//  GAMSS
//
//  Created by 이건준 on 8/15/26.
//

import Foundation

enum ConversationError: Error {
    case invalidSearchKeyword
}

extension ConversationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidSearchKeyword:
            return "검색어는 2자 이상 입력해주세요."
        }
    }
}
