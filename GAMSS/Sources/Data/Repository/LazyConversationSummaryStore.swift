//
//  LazyConversationSummaryStore.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

import Foundation

/// DefaultSummaryRepository.make()가 async throws라 화면 생성 시점에 바로 만들 수 없다.
/// 실제로 처음 쓰일 때(add/current/restore 최초 호출) 한 번만 만들어 캐싱한다.
/// 생성에 실패해도(예: 모델 로드 실패) 압축은 부가 기능이므로 조용히 무시한다.
actor LazyConversationSummaryStore: ConversationSummaryStore {
    private let makeRepository: () async throws -> SummaryRepository
    private var underlying: DefaultConversationSummaryStore?
    private var resolutionFailed = false

    init(makeRepository: @escaping () async throws -> SummaryRepository = { try await DefaultSummaryRepository.make() }) {
        self.makeRepository = makeRepository
    }

    func add(_ utterance: String) async {
        await resolve()?.add(utterance)
    }

    func current() async -> String? {
        await resolve()?.current()
    }

    func reset() async {
        await resolve()?.reset()
    }

    func restore(historicalUtterances: [String]) async {
        await resolve()?.restore(historicalUtterances: historicalUtterances)
    }

    private func resolve() async -> DefaultConversationSummaryStore? {
        if let underlying { return underlying }
        guard !resolutionFailed, let repository = try? await makeRepository() else {
            resolutionFailed = true
            return nil
        }
        let store = DefaultConversationSummaryStore(summaryRepository: repository)
        underlying = store
        return store
    }
}
