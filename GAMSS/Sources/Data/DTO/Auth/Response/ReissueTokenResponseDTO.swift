//
//  ReissueTokenResponseDTO.swift
//  GAMSS
//
//  Created by 이건준 on 8/8/26.
//

import Foundation

struct ReissueTokenResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}
