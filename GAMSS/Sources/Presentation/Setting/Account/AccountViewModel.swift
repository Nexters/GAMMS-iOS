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
    private let deleteMemberUseCase: DeleteMemberUseCase
    private let userManager: UserManager
    
    @Published var errorMessage: String?
    
    init(
        logoutUseCase: LogoutUseCase,
        deleteMemberUseCase: DeleteMemberUseCase,
        userManager: UserManager = .shared
    ) {
        self.logoutUseCase = logoutUseCase
        self.deleteMemberUseCase = deleteMemberUseCase
        self.userManager = userManager
    }
    
    func deleteMember() async {
        do {
            try await deleteMemberUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
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
