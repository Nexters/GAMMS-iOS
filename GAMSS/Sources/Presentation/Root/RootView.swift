//
//  RootView.swift
//  GAMSS
//
//  Created by 이건준 on 8/12/26.
//

import SwiftUI

@Observable
final class LoginSession {
    var value: LoginState = .current
}

struct RootView: View {
    @State private var loginSession = LoginSession()
    
    var body: some View {
        Group {
            switch loginSession.value {
            case .notLoggedIn:
                LoginView(
                    viewModel: LoginViewModel(
                        loginUseCase: DefaultLoginUseCase(
                            authRepository: DefaultAuthRepository(
                                networkManager: NetworkManager.shared,
                                tokenStorage: TokenStorage.shared
                            )
                        )
                    )
                )
            case .autoLoginPending, .loggedIn:
                MainTabView()
            }
        }
        .environment(loginSession)
        .environment(UserManager.shared)
    }
}

#Preview {
    RootView()
}
