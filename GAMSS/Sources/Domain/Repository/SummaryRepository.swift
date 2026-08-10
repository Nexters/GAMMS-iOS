//
//  SummaryRepository.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

protocol SummaryRepository {
    func summarize(text: String) async throws -> String
    /// 절단 없이 실제 토큰 수를 돌려준다 — 청크 경계를 정확히 재는 용도.
    func countTokens(text: String) async throws -> Int
}
