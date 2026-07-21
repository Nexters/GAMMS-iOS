//
//  GAMSSApp.swift
//  GAMSS
//
//  Created by 이건준 on 7/12/26.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct GAMSSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            LoginView(viewModel: LoginViewModel(loginUseCase: DefaultLoginUseCase(authRepository: DefaultAuthRepository(networkManager: NetworkManager.shared))))
        }
    }
}
