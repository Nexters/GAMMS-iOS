//
//  RiskLexiconCache.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

import Foundation

struct RiskLexiconCache {
    private let userDefaults: UserDefaults
    private let ttl: TimeInterval

    init(userDefaults: UserDefaults = .standard, ttl: TimeInterval = 24 * 60 * 60) {
        self.userDefaults = userDefaults
        self.ttl = ttl
    }

    func read() -> RiskLexiconDTO? {
        guard let data = userDefaults.data(forKey: Keys.json) else { return nil }
        return try? JSONDecoder().decode(RiskLexiconDTO.self, from: data)
    }

    func write(_ dto: RiskLexiconDTO) {
        guard let data = try? JSONEncoder().encode(dto) else { return }
        userDefaults.set(data, forKey: Keys.json)
        userDefaults.set(Date().timeIntervalSince1970, forKey: Keys.fetchedAt)
    }

    func markFetched() {
        userDefaults.set(Date().timeIntervalSince1970, forKey: Keys.fetchedAt)
    }

    var isStale: Bool {
        let fetchedAt = userDefaults.double(forKey: Keys.fetchedAt)
        guard fetchedAt > 0 else { return true }
        return Date().timeIntervalSince1970 - fetchedAt >= ttl
    }

    private enum Keys {
        static let json = "risk_lexicon_cache_json"
        static let fetchedAt = "risk_lexicon_cache_fetched_at"
    }
}
