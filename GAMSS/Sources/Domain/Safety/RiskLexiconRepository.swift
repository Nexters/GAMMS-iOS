//
//  RiskLexiconRepository.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

protocol RiskLexiconRepository {
    func currentLexicon() async -> RiskLexicon
    func refresh() async
}
