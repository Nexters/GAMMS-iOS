//
//  DetectRiskInTextUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

struct DetectRiskInTextUseCase {
    private let repository: RiskLexiconRepository
    private let matcher: RiskTermMatcher

    init(repository: RiskLexiconRepository, matcher: RiskTermMatcher = RiskTermMatcher()) {
        self.repository = repository
        self.matcher = matcher
    }

    func execute(text: String) async -> RiskDetection {
        let lexicon = await repository.currentLexicon()
        return matcher.match(text: text, lexicon: lexicon)
    }
}
