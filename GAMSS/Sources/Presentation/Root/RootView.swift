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
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        ZStack {
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
                if hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView {
                        hasCompletedOnboarding = true
                    }
                }
            }
        }
        .task {
            await RefreshRiskLexiconUseCase(repository: DefaultRiskLexiconRepository()).execute()
        }
        .animation(
            .easeInOut(duration: 0.3),
            value: loginSession.value
        )
        .animation(
            .easeInOut(duration: 0.3),
            value: hasCompletedOnboarding
        )
        .environment(loginSession)
        .environment(UserManager.shared)
    }
}

#Preview {
    RootView()
}
