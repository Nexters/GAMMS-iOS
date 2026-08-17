//
//  AccountError.swift
//  GAMSS
//
//  Created by 이건준 on 8/16/26.
//

import Foundation

enum AccountError: Error {
    case invalidNickname
}

extension AccountError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidNickname:
            return "닉네임은 2자 이상 20자 이하로 입력해주세요."
        }
    }
}
