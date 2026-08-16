//
//  UpdateNicknameResponseDTO.swift
//  GAMSS
//
//  Created by 이건준 on 8/16/26.
//

import Foundation

struct UpdateNicknameResponseDTO: Decodable {
    let id: Int
    let email: String
    let name: String?
    let nickname: String
    let status: String
    let createdAt: String
}
