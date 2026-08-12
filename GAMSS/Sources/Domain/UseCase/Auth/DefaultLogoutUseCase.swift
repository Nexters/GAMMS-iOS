//
//  DefaultLogoutUseCase.swift
//  GAMSS
//
//  Created by 이건준 on 8/13/26.
//

import Foundation

final class DefaultLogoutUseCase: LogoutUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func logout() async throws {
        try await authRepository.logout()
    }
}
