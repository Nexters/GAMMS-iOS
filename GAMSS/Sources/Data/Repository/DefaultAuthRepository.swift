//
//  AuthService.swift
//  GAMSS
//
//  Created by 이건준 on 7/13/26.
//

import AuthenticationServices

import FirebaseAuth

final class DefaultAuthRepository: AuthRepository {
    private let networkManager: NetworkRequesting
    private let tokenStorage: TokenStorage
    
    init(
        networkManager: NetworkRequesting,
        tokenStorage: TokenStorage
    ) {
        self.networkManager = networkManager
        self.tokenStorage = tokenStorage
    }
    
    func logout() async throws {
        _ = try await networkManager.request(AuthEndpoint.logout, responseType: APIResponse<EmptyResponseDTO>.self)
        try tokenStorage.deleteTokens()
        try? Auth.auth().signOut()
    }

    func autoLogin() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.missingFirebaseUser
        }

        let firebaseIdToken: String
        do {
            firebaseIdToken = try await user.getIDToken(forcingRefresh: true)
        } catch {
            throw AuthError.firebaseSignInFailed(error)
        }

        try await login(firebaseIdToken: firebaseIdToken)
    }
    
    func login(
        with socialType: SocialType,
        credential: ASAuthorizationAppleIDCredential,
        nonce: String
    ) async throws {
        switch socialType {
        case .apple:
            try await loginWithApple(
                credential: credential,
                nonce: nonce
            )
        }
    }
    
    private func loginWithApple(
        credential: ASAuthorizationAppleIDCredential,
        nonce: String
    ) async throws {
        let firebaseIdToken = try await signInFirebase(
            credential: credential,
            nonce: nonce
        )
        
        try await login(firebaseIdToken: firebaseIdToken)
    }
    
    
    private func signInFirebase(
        credential: ASAuthorizationAppleIDCredential,
        nonce: String
    ) async throws -> String {
        guard let identityToken = credential.identityToken else {
            throw AuthError.missingIdentityToken
        }
        
        guard let idToken = String(
            data: identityToken,
            encoding: .utf8
        ) else {
            throw AuthError.invalidIdentityToken
        }
        
        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: credential.fullName
        )
        
        do {
            let authResult = try await Auth.auth().signIn(
                with: firebaseCredential
            )
            
            return try await authResult.user.getIDToken()
            
        } catch {
            throw AuthError.firebaseSignInFailed(error)
        }
    }
    
    private func login(
        firebaseIdToken: String
    ) async throws {
        // 로그인/자동로그인 중 401이 나도 재발급→자동로그인 루프에 들어가지 않도록 한다.
        let response = try await networkManager.request(
            AuthEndpoint.login(.init(idToken: firebaseIdToken)),
            responseType: APIResponse<LoginResponseDTO>.self,
            isRetryAfterReissue: true
        )
        
        do {
            try tokenStorage.createTokens(
                accessToken: response.data.accessToken,
                refreshToken: response.data.refreshToken
            )
        } catch {
            throw AuthError.tokenStorageFailed(error)
        }
    }
}
