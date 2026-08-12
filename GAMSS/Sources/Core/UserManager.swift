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
    
    private init() {}
}
