//
//  AccountViewModel.swift
//  GAMSS
//
//  Created by LEEGEONJUN on 8/13/26.
//

import Combine
import Foundation

@MainActor
final class AccountViewModel: ObservableObject {
    private let logoutUseCase: LogoutUseCase
    private let userManager: UserManager
    
    @Published var errorMessage: String?
    
    init(
        logoutUseCase: LogoutUseCase,
        userManager: UserManager = .shared
    ) {
        self.logoutUseCase = logoutUseCase
        self.userManager = userManager
    }
    
    func logout() async {
        do {
            try await logoutUseCase.logout()
            userManager.user = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
