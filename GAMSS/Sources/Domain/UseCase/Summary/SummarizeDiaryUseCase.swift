//
//  SummarizeDiaryUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 7/29/26.
//

protocol SummarizeDiaryUseCase {
    func execute(text: String) async throws -> String?
}
