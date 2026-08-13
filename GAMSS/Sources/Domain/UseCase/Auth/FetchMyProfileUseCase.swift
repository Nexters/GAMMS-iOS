//
//  FetchMyProfileUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import Foundation

protocol FetchMyProfileUseCase {
    func execute() async throws -> User
}
