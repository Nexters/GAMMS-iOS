//
//  UpdateNicknameUseCase.swift
//  GAMSS
//
//  Created by 이건준 on 8/16/26.
//

import Foundation

protocol UpdateNicknameUseCase {
    func execute(_ nickname: String) async throws
}
