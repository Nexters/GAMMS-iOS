//
//  RequestParameter.swift
//  GAMSS
//
//  Created by 이건준 on 8/8/26.
//

import Foundation

enum RequestParameter {
    case query([String: String])
    case body(Encodable)
}
