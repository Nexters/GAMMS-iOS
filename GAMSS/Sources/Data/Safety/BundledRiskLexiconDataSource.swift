//
//  BundledRiskLexiconDataSource.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

import Foundation

struct BundledRiskLexiconDataSource {
    func load() -> RiskLexiconDTO? {
        guard let url = Bundle.main.url(forResource: "risk_lexicon", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(RiskLexiconDTO.self, from: data)
    }
}
