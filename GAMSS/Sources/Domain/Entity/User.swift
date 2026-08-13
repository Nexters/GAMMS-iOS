//
//  User.swift
//  GAMSS
//
//  Created by 이건준 on 8/13/26.
//

import Foundation

struct User {
    let id: Int
    let email: String
    // 서버가 아직 이름/닉네임을 설정하지 않은 사용자(가입 직후 등)에게는 null을 내려준다
    // (실기기 확인함: {"id":3,...,"name":null,"nickname":null,...}) — optional로 받는다.
    let name: String?
    let nickname: String?
}
