//
//  DetectRiskInTextUseCaseTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

import XCTest
@testable import GAMSS

private final class MockRiskLexiconRepository: RiskLexiconRepository {
    var stubbedLexicon: RiskLexicon = .empty
    private(set) var refreshCallCount = 0

    func currentLexicon() async -> RiskLexicon { stubbedLexicon }

    func refresh() async { refreshCallCount += 1 }
}

final class DetectRiskInTextUseCaseTests: XCTestCase {
    func test_execute_delegatesToMatcherWithRepositoryLexicon() async {
        let repository = MockRiskLexiconRepository()
        repository.stubbedLexicon = RiskLexicon(
            version: 1,
            terms: [RiskTerm(term: "자살", level: .critical)],
            safePhrases: [],
            agencies: [SupportAgency(id: "a", name: "자살예방", description: "", phoneNumber: "109", url: nil, priority: 1, isEmergency: false)]
        )
        let useCase = DetectRiskInTextUseCase(repository: repository, matcher: RiskTermMatcher())

        let detection = await useCase.execute(text: "자살하고싶다")

        XCTAssertEqual(detection.level, .critical)
        XCTAssertEqual(detection.agencies.map(\.name), ["자살예방"])
    }

    func test_execute_emptyLexicon_returnsNone() async {
        let repository = MockRiskLexiconRepository()
        let useCase = DetectRiskInTextUseCase(repository: repository, matcher: RiskTermMatcher())

        let detection = await useCase.execute(text: "자살하고싶다")

        XCTAssertEqual(detection, .none)
    }
}

final class RefreshRiskLexiconUseCaseTests: XCTestCase {
    func test_execute_delegatesToRepositoryRefresh() async {
        let repository = MockRiskLexiconRepository()
        let useCase = RefreshRiskLexiconUseCase(repository: repository)

        await useCase.execute()

        XCTAssertEqual(repository.refreshCallCount, 1)
    }
}
