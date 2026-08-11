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
            MainTabView()
                .preferredColorScheme(.light)
        }
        // 디자인 토큰이 다크모드 값을 갖고 있지만 디자이너가 아직 다크모드 화면을 설계하지
        // 않았다 — 시스템 다크모드를 그대로 따라가면 색상이 라이트/다크 목적과 반대로
        // 뒤집혀 보이므로 앱 전체를 라이트 모드로 고정한다.
    }
}
