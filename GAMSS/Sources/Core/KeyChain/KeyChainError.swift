//
//  KeyChainError.swift
//  GAMSS
//
//  Created by 이건준 on 7/29/26.
//

import Foundation

enum KeyChainError: LocalizedError {
    case unhandledError(status: OSStatus)
    case itemNotFound
    
    var errorDescription: String? {
        switch self {
        case .unhandledError(let status):
            return "KeyChain unhandle Error: \(status)"
        case .itemNotFound:
            return "KeyChain item Not Found"
        }
    }
}
