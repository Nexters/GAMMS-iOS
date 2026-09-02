//
//  LoginSession.swift
//  GAMSS
//
//  Created by 이건준 on 8/12/26.
//

import Foundation

@Observable
@MainActor
final class LoginSession {
    static let shared = LoginSession()

    var value: LoginState = .current

    private init() {}

    func updateFromStorage() {
        value = .current
    }
}
