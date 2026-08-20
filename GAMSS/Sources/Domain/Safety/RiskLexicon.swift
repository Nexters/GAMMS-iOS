//
//  RiskLexicon.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

struct RiskLexicon: Equatable {
    let version: Int
    let terms: [RiskTerm]
    let safePhrases: [String]
    let agencies: [SupportAgency]

    static let empty = RiskLexicon(version: 0, terms: [], safePhrases: [], agencies: [])
}
