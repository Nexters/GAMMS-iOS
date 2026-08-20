//
//  DefaultRiskLexiconRepository.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

final class DefaultRiskLexiconRepository: RiskLexiconRepository {
    private let bundled: BundledRiskLexiconDataSource
    private let cache: RiskLexiconCache
    private let fetchRemote: () async throws -> RiskLexiconDTO

    init(
        bundled: BundledRiskLexiconDataSource = BundledRiskLexiconDataSource(),
        cache: RiskLexiconCache = RiskLexiconCache(),
        fetchRemote: @escaping () async throws -> RiskLexiconDTO = { try await FirestoreRiskLexiconDataSource().fetch() }
    ) {
        self.bundled = bundled
        self.cache = cache
        self.fetchRemote = fetchRemote
    }

    func currentLexicon() async -> RiskLexicon {
        let cachedDTO = cache.read().flatMap { dto -> RiskLexiconDTO? in
            (!dto.terms.isEmpty && !dto.agencies.isEmpty) ? dto : nil
        }
        let bundledDTO = bundled.load() ?? RiskLexiconDTO(version: 0, terms: [], safePhrases: [], agencies: [])
        if let cachedDTO, cachedDTO.version >= bundledDTO.version {
            return cachedDTO.toDomain()
        }
        return bundledDTO.toDomain()
    }

    func refresh() async {
        guard cache.isStale else { return }
        guard let fetched = try? await fetchRemote() else { return }
        cache.markFetched()
        guard !fetched.terms.isEmpty, !fetched.agencies.isEmpty else { return }
        let cachedVersion = cache.read()?.version ?? bundled.load()?.version ?? 0
        guard fetched.version > cachedVersion else { return }
        cache.write(fetched)
    }
}
