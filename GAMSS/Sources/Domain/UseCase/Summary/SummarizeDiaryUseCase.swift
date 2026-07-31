//
//  SummarizeDiaryUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 7/29/26.
//

protocol SummarizeDiaryUseCase {
    func addUtterance(_ text: String) async
    func finalize() async throws -> String?
}
