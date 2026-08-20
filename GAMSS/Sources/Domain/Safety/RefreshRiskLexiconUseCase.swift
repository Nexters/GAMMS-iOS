//
//  RefreshRiskLexiconUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

struct RefreshRiskLexiconUseCase {
    private let repository: RiskLexiconRepository

    init(repository: RiskLexiconRepository) {
        self.repository = repository
    }

    func execute() async {
        await repository.refresh()
    }
}
