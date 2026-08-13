//
//  AccountItem.swift
//  GAMSS
//
//  Created by LEEGEONJUN on 8/13/26.
//

import SwiftUI

enum AccountItem: CaseIterable, Identifiable {
    case changeNickname
    case email
    case logout
    case withdraw
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .changeNickname:
            "닉네임 변경"
        case .email:
            "이메일"
        case .logout:
            "로그아웃"
        case .withdraw:
            "회원탈퇴"
        }
    }
    
    var titleColor: Color {
        switch self {
        case .withdraw:
            .colorRed
        case .changeNickname, .email, .logout:
            .colorGray950
        }
    }
    
    enum Action {
        case navigate
        case logout
        case withdraw
        case none
    }
    
    var action: Action {
        switch self {
        case .changeNickname:
            .navigate
        case .email:
            .none
        case .logout:
            .logout
        case .withdraw:
            .withdraw
        }
    }
}
