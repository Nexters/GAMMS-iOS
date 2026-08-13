//
//  UserManager.swift
//  GAMSS
//
//  Created by 이건준 on 8/13/26.
//

import Foundation

@Observable
final class UserManager {
    static let shared = UserManager()
    
    var user: User?

    // 테스트에서 격리된 인스턴스를 주입할 수 있도록 internal로 둔다(.shared는 실제 앱에서
    // 계속 유일 인스턴스로 쓰면 됨 — 이 변경은 그 사용 방식을 바꾸지 않는다).
    init() {}
}
