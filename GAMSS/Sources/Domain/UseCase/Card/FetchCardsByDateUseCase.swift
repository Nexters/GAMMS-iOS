//
//  FetchCardsByDateUseCase.swift
//  GAMSS
//
//  Created by 이건준 on 8/18/26.
//

import Foundation

protocol FetchCardsByDateUseCase {
    func execute(yearMonth: Date) async throws -> [DailyEmotion]
}
