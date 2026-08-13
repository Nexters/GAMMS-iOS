//
//  MemberProfileResponseDTO.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import Foundation

struct MemberProfileResponseDTO: Decodable {
    let id: Int
    let email: String
    let name: String
    let nickname: String

    func toDomain() -> User {
        User(id: id, email: email, name: name, nickname: nickname)
    }
}
