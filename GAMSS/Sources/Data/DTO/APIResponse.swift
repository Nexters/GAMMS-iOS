//
//  APIResponse.swift
//  GAMSS
//
//  Created by 이건준 on 7/29/26.
//

import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T
    let error: ErrorResponse?
}

struct ErrorResponse: Decodable {
    let code: String
    let message: String
}
