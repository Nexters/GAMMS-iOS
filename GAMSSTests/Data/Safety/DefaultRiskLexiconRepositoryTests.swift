//
//  DefaultRiskLexiconRepositoryTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

import XCTest
@testable import GAMSS

final class DefaultRiskLexiconRepositoryTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var cache: RiskLexiconCache!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        cache = RiskLexiconCache(userDefaults: userDefaults)
    }

    func test_currentLexicon_noCacheYet_returnsBundled() async {
        let repository = DefaultRiskLexiconRepository(
            bundled: BundledRiskLexiconDataSource(),
            cache: cache,
            fetchRemote: { RiskLexiconDTO(version: 999, terms: [], safePhrases: [], agencies: []) }
        )

        let lexicon = await repository.currentLexicon()

        XCTAssertGreaterThan(lexicon.terms.count, 0)
    }

    func test_refresh_staleCache_adoptsHigherVersionRemote() async {
        cache.write(RiskLexiconDTO(version: 1, terms: [RiskTermDTO(term: "old", level: "WARNING")], safePhrases: [], agencies: [SupportAgencyDTO(id: "a", name: "A", description: "", phoneNumber: "1", url: nil, priority: 1)]))
        let staleCache = RiskLexiconCache(userDefaults: userDefaults, ttl: -1)
        let repository = DefaultRiskLexiconRepository(
            bundled: BundledRiskLexiconDataSource(),
            cache: staleCache,
            fetchRemote: { RiskLexiconDTO(version: 5, terms: [RiskTermDTO(term: "new", level: "CRITICAL")], safePhrases: [], agencies: [SupportAgencyDTO(id: "a", name: "A", description: "", phoneNumber: "1", url: nil, priority: 1)]) }
        )

        await repository.refresh()

        XCTAssertEqual(staleCache.read()?.version, 5)
    }

    func test_refresh_remoteVersionNotHigher_keepsCache() async {
        cache.write(RiskLexiconDTO(version: 10, terms: [RiskTermDTO(term: "old", level: "WARNING")], safePhrases: [], agencies: [SupportAgencyDTO(id: "a", name: "A", description: "", phoneNumber: "1", url: nil, priority: 1)]))
        let staleCache = RiskLexiconCache(userDefaults: userDefaults, ttl: -1)
        let repository = DefaultRiskLexiconRepository(
            bundled: BundledRiskLexiconDataSource(),
            cache: staleCache,
            fetchRemote: { RiskLexiconDTO(version: 2, terms: [], safePhrases: [], agencies: [SupportAgencyDTO(id: "a", name: "A", description: "", phoneNumber: "1", url: nil, priority: 1)]) }
        )

        await repository.refresh()

        XCTAssertEqual(staleCache.read()?.version, 10)
    }

    func test_refresh_remoteFetchThrows_doesNotCrashOrChangeCache() async {
        cache.write(RiskLexiconDTO(version: 1, terms: [], safePhrases: [], agencies: []))
        let staleCache = RiskLexiconCache(userDefaults: userDefaults, ttl: -1)
        staleCache.write(RiskLexiconDTO(version: 1, terms: [], safePhrases: [], agencies: []))
        let repository = DefaultRiskLexiconRepository(
            bundled: BundledRiskLexiconDataSource(),
            cache: staleCache,
            fetchRemote: { throw RiskLexiconFetchError.documentNotFound }
        )

        await repository.refresh()

        XCTAssertEqual(staleCache.read()?.version, 1)
    }

    func test_refresh_remoteEmptyAgenciesOrTerms_isRejected() async {
        let staleCache = RiskLexiconCache(userDefaults: userDefaults, ttl: -1)
        staleCache.write(RiskLexiconDTO(version: 1, terms: [], safePhrases: [], agencies: []))
        let repository = DefaultRiskLexiconRepository(
            bundled: BundledRiskLexiconDataSource(),
            cache: staleCache,
            fetchRemote: { RiskLexiconDTO(version: 99, terms: [], safePhrases: [], agencies: []) }
        )

        await repository.refresh()

        XCTAssertEqual(staleCache.read()?.version, 1)
    }

    func test_refresh_freshCache_doesNotCallRemote() async {
        cache.write(RiskLexiconDTO(version: 1, terms: [], safePhrases: [], agencies: []))
        var remoteCalled = false
        let repository = DefaultRiskLexiconRepository(
            bundled: BundledRiskLexiconDataSource(),
            cache: cache,
            fetchRemote: { remoteCalled = true; return RiskLexiconDTO(version: 2, terms: [], safePhrases: [], agencies: []) }
        )

        await repository.refresh()

        XCTAssertFalse(remoteCalled)
    }

    func test_currentLexicon_cacheHasEmptyTermsOrAgencies_fallsBackToBundled() async {
        cache.write(RiskLexiconDTO(version: 99, terms: [], safePhrases: [], agencies: []))
        let repository = DefaultRiskLexiconRepository(
            bundled: BundledRiskLexiconDataSource(),
            cache: cache,
            fetchRemote: { RiskLexiconDTO(version: 1, terms: [], safePhrases: [], agencies: []) }
        )

        let lexicon = await repository.currentLexicon()

        XCTAssertGreaterThan(lexicon.terms.count, 0)
    }

    func test_refresh_remoteVersionNotHigher_stampsFetchedAtAnyway() async {
        let seedDTO = RiskLexiconDTO(version: 10, terms: [RiskTermDTO(term: "old", level: "WARNING")], safePhrases: [], agencies: [SupportAgencyDTO(id: "a", name: "A", description: "", phoneNumber: "1", url: nil, priority: 1)])
        userDefaults.set(try! JSONEncoder().encode(seedDTO), forKey: "risk_lexicon_cache_json")
        userDefaults.set(0.0, forKey: "risk_lexicon_cache_fetched_at")
        let staleCache = RiskLexiconCache(userDefaults: userDefaults, ttl: -1)
        let repository = DefaultRiskLexiconRepository(
            bundled: BundledRiskLexiconDataSource(),
            cache: staleCache,
            fetchRemote: { RiskLexiconDTO(version: 2, terms: [RiskTermDTO(term: "new", level: "WARNING")], safePhrases: [], agencies: [SupportAgencyDTO(id: "a", name: "A", description: "", phoneNumber: "1", url: nil, priority: 1)]) }
        )

        await repository.refresh()

        let freshCheckCache = RiskLexiconCache(userDefaults: userDefaults)
        XCTAssertFalse(freshCheckCache.isStale)
    }

    func test_currentLexicon_bundledVersionHigherThanCache_prefersBundled() async {
        cache.write(RiskLexiconDTO(version: 0, terms: [RiskTermDTO(term: "old", level: "WARNING")], safePhrases: [], agencies: [SupportAgencyDTO(id: "a", name: "A", description: "", phoneNumber: "1", url: nil, priority: 1)]))
        let repository = DefaultRiskLexiconRepository(
            bundled: BundledRiskLexiconDataSource(),
            cache: cache,
            fetchRemote: { RiskLexiconDTO(version: 1, terms: [], safePhrases: [], agencies: []) }
        )

        let lexicon = await repository.currentLexicon()

        XCTAssertNotEqual(lexicon.terms.map(\.term), ["old"])
    }
}
