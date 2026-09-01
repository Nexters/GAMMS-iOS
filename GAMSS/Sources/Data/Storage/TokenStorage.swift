//
//  TokenStorage.swift
//  GAMSS
//
//  Created by 이건준 on 7/29/26.
//

import FirebaseAuth
import Foundation

final class TokenStorage {
    static let shared = TokenStorage()

    private lazy var authRepository: AuthRepository = DefaultAuthRepository(
        networkManager: NetworkManager.shared,
        tokenStorage: self
    )

    private init() {}

    /// refresh 재발급을 시도하고, 실패하면 Firebase 세션으로 로그인 API를 다시 호출한다.
    func restoreSession() async throws {
        if let refreshToken = readToken(.refreshToken) {
            do {
                try await reissue(refreshToken: refreshToken)
                return
            } catch {
                Log.error("Token reissue failed, trying auto login: \(error)")
            }
        } else {
            try deleteTokens()
        }

        try await authRepository.autoLogin()
    }

    func createTokens(accessToken: String, refreshToken: String) throws {
        try KeyChainManager.shared.create(account: .accessToken, data: accessToken)
        try KeyChainManager.shared.create(account: .refreshToken, data: refreshToken)
        Log.info("[Token updated]\naccessToken: \(accessToken)\nrefreshToken: \(refreshToken)", privacy: .privacy)
    }

    func setToken(_ token: String, for account: KeyChainAccount) throws {
        try KeyChainManager.shared.create(account: account, data: token)
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

    func deleteTokens() throws {
        try KeyChainManager.shared.delete(account: .accessToken)
        try KeyChainManager.shared.delete(account: .refreshToken)
        Log.info("[Token Deleted]")
    }

    func clearSession() {
        try? deleteTokens()
        try? Auth.auth().signOut()
    }

    private func reissue(refreshToken: String) async throws {
        let response = try await NetworkManager.shared.request(
            AuthEndpoint.reissueToken(.init(refreshToken: refreshToken)),
            responseType: APIResponse<ReissueTokenResponseDTO>.self,
            isRetryAfterReissue: true
        ).data
        try createTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
    }
}
