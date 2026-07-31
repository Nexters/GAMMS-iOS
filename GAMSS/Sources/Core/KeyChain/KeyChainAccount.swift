//
//  KeyChainAccount.swift
//  GAMSS
//
//  Created by 이건준 on 7/29/26.
//

import Foundation

enum KeyChainAccount {
    case accessToken
    case refreshToken
    
    var description: String {
        return String(describing: self)
    }
    
    var keyChainClass: CFString {
        switch self {
        case .accessToken, .refreshToken:
            return kSecClassGenericPassword
        }
    }
}

