//
//  TokenStorage.swift
//  GAMSS
//
//  Created by 이건준 on 7/29/26.
//

import Foundation

final class TokenStorage {
    static let shared = TokenStorage()
    
    private init() {}
    
    func reissueToken() {
        guard LoginState.current != .notLoggedIn else {
            TokenStorage.shared.deleteTokens()
            return
        }
        
        /// TODO: - accessToken, refreshToken 재발행 로직 필요
    }
    
    func createTokens(accessToken: String, refreshToken: String) {
        do {
            try KeyChainManager.shared.create(account: .accessToken, data: accessToken)
            try KeyChainManager.shared.create(account: .refreshToken, data: refreshToken)
            Log.info("[Token updated]\naccessToken: \(accessToken)\nrefreshToken: \(refreshToken)", privacy: .privacy)
        } catch {
            Log.error("\(error.localizedDescription): \(error)")
        }
    }
    
    func setToken(_ token: String, for account: KeyChainAccount) {
        do {
            try KeyChainManager.shared.create(account: account, data: token)
        } catch {
            Log.error("\(error.localizedDescription): \(error)")
        }
    }
    
    func readToken(_ account: KeyChainAccount) -> String? {
        do {
            let token = try KeyChainManager.shared.read(account: account)
            return token
        } catch {
            Log.error("\(error.localizedDescription): \(error)")
            return nil
        }
    }
    
    func deleteTokens() {
        do {
            try KeyChainManager.shared.delete(account: .accessToken)
            try KeyChainManager.shared.delete(account: .refreshToken)
            Log.info("[Token Deleted]")
        } catch {
            Log.error("\(error.localizedDescription): \(error)")
        }
    }
}

