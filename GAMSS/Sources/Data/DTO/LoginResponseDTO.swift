//
//  LoginResponseDTO.swift
//  GAMSS
//
//  Created by 이건준 on 7/29/26.
//

import Foundation

struct LoginResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}
