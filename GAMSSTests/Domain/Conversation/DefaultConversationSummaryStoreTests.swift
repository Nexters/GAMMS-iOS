//
//  DefaultConversationSummaryStoreTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import XCTest
@testable import GAMSS

/// countTokens는 text.count(1글자=1토큰)로 고정해서, 발화 길이만으로 청크 경계를 정확히 통제한다.
private actor MockSummaryRepository: SummaryRepository {
    private(set) var summarizeCallCount = 0
    private(set) var summarizedTexts: [String] = []
    var stubbedSummary = "요약됨"
    var shouldThrowOnSummarize = false

    func summarize(text: String) async throws -> String {
        summarizeCallCount += 1
        summarizedTexts.append(text)
        if shouldThrowOnSummarize { throw SummaryError.inferenceFailed() }
        return stubbedSummary
    }

    func countTokens(text: String) async throws -> Int {
        text.count
    }
}

final class DefaultConversationSummaryStoreTests: XCTestCase {
    private func makeStore(repository: MockSummaryRepository = MockSummaryRepository()) -> (DefaultConversationSummaryStore, MockSummaryRepository) {
        (DefaultConversationSummaryStore(summaryRepository: repository), repository)
    }

    func test_current_whenEmpty_returnsNil() async {
        let (store, _) = makeStore()
        let result = await store.current()
        XCTAssertNil(result)
    }

    func test_current_withFewerThanRecentWindow_returnsAllRawWithNoDuplication() async {
        let (store, repository) = makeStore()
        await store.add("발화1")
        await store.add("발화2")

        let result = await store.current()

        XCTAssertEqual(result, "발화1 발화2")
        let callCount = await repository.summarizeCallCount
        XCTAssertEqual(callCount, 0)
    }

    func test_current_firstUtterance_staysRawAsConversationGrows() async {
        let (store, _) = makeStore()
        // 100자짜리 발화 10개: 첫 발화는 절대 후보에 안 들어가므로 원문 그대로 맨 앞에 남아야 한다.
        let first = String(repeating: "가", count: 100)
        await store.add(first)
        for i in 1..<10 {
            await store.add(String(repeating: "\(i % 10)", count: 100))
        }

        let result = await store.current()

        XCTAssertTrue(result?.hasPrefix(first) ?? false, "첫 발화가 압축본 맨 앞에 원문으로 남아있어야 함")
    }

    func test_add_closesChunkExactlyOnceWhenBudgetExceeded() async {
        let (store, repository) = makeStore()
        // 100토큰짜리 발화를 10개 추가하면: recentStart는 매 add마다 갱신되고,
        // 10번째 발화 추가 시점에 pending(발화1~5, 500토큰) + 발화6(100토큰) = 600 > 512라
        // 발화6을 넣기 전에 먼저 확정(summarize 1회 호출)된다.
        for i in 0..<10 {
            await store.add(String(repeating: "\(i)", count: 100))
        }

        let callCount = await repository.summarizeCallCount
        XCTAssertEqual(callCount, 1, "정확히 한 번만 요약이 확정되어야 함")
    }

    func test_add_closedChunkIsNeverReSummarized() async {
        let (store, repository) = makeStore()
        for i in 0..<10 {
            await store.add(String(repeating: "\(i)", count: 100))
        }
        let callCountAfterFirstClose = await repository.summarizeCallCount
        XCTAssertEqual(callCountAfterFirstClose, 1)

        // 발화를 더 추가해도 이미 확정된 청크는 다시 요약되지 않는다.
        await store.add(String(repeating: "x", count: 50))
        await store.add(String(repeating: "y", count: 50))

        let callCountAfterMore = await repository.summarizeCallCount
        XCTAssertEqual(callCountAfterMore, 1, "이미 확정된 청크가 재요약되면 안 됨")
    }

    func test_add_singleUtteranceOverBudget_confirmsAsRawWithoutSummarizing() async {
        let (store, repository) = makeStore()
        let huge = String(repeating: "가", count: 600) // 단일 발화가 이미 512토큰 초과
        // 첫 발화(짧게) + 거대 발화 + 채움용 발화 3개로 거대 발화를 후보 구간에 들어오게 만든다.
        await store.add("첫발화")
        await store.add(huge)
        await store.add("채움1")
        await store.add("채움2")
        await store.add("채움3")

        let callCount = await repository.summarizeCallCount
        XCTAssertEqual(callCount, 0, "예산을 초과한 단일 발화는 요약하지 않고 원문으로 확정해야 함")
        let result = await store.current()
        XCTAssertTrue(result?.contains(huge) ?? false, "예산 초과 발화는 원문 그대로 압축본에 포함되어야 함")
    }

    func test_current_recentThreeUtterances_alwaysRawRegardlessOfChunking() async {
        let (store, _) = makeStore()
        for i in 0..<12 {
            await store.add(String(repeating: "\(i)", count: 100))
        }
        let last = String(repeating: "9", count: 100)
        await store.add(last)

        let result = await store.current()

        XCTAssertTrue(result?.hasSuffix(last) ?? false, "가장 최근 발화가 압축본 맨 뒤에 원문으로 남아있어야 함")
    }

    func test_current_exceedsMaxLength_dropsOldestMiddleContentFirst() async {
        let (store, _) = makeStore()
        let first = String(repeating: "첫", count: 100)
        await store.add(first)
        // 중간 발화를 아주 많이 넣어서(2000자 상한을 확실히 넘기도록) 오래된 확정 청크가 버려지는지 확인.
        for i in 0..<30 {
            await store.add(String(repeating: "\(i % 10)", count: 100))
        }
        let recent = ["최근1", "최근2", "최근3"]
        for utterance in recent {
            await store.add(utterance)
        }

        let result = await store.current()

        XCTAssertNotNil(result)
        XCTAssertLessThanOrEqual(result?.count ?? .max, ConversationSummaryPolicy.maxContextSummaryLength)
        XCTAssertTrue(result?.hasPrefix(first) ?? false, "상한을 넘겨도 첫 발화는 항상 보존되어야 함")
        for utterance in recent {
            XCTAssertTrue(result?.contains(utterance) ?? false, "상한을 넘겨도 최근 발화는 항상 보존되어야 함: \(utterance)")
        }
    }

    func test_reset_clearsAllState() async {
        let (store, _) = makeStore()
        await store.add("발화1")
        await store.add("발화2")

        await store.reset()

        let result = await store.current()
        XCTAssertNil(result)
    }

    func test_restore_neverCallsSummarize() async {
        let (store, repository) = makeStore()
        // 100자짜리 발화 20개를 복원 — 일반 add()였다면 여러 번 요약이 트리거될 양이지만
        // restore()는 절대 요약을 호출하면 안 된다.
        let historical = (0..<20).map { String(repeating: "\($0 % 10)", count: 100) }

        await store.restore(historicalUtterances: historical)

        let callCount = await repository.summarizeCallCount
        XCTAssertEqual(callCount, 0, "재진입 복원은 절대 요약을 호출하면 안 됨")
    }

    func test_restore_thenAddingNewUtterance_doesNotReprocessRestoredMiddle() async {
        let (store, repository) = makeStore()
        let historical = (0..<20).map { String(repeating: "\($0 % 10)", count: 100) }
        await store.restore(historicalUtterances: historical)

        // 복원 후 새 발화를 추가해도, 이미 복원된 "중간 구간"은 재청킹되지 않아야 한다
        // (다음 후보 인덱스가 최근창 시작으로 이미 옮겨져 있으므로).
        await store.add("새발화")

        let callCount = await repository.summarizeCallCount
        XCTAssertEqual(callCount, 0, "복원된 중간 구간이 재청킹/재요약되면 안 됨")
    }

    func test_restore_withEmptyHistory_resultsInEmptyStore() async {
        let (store, _) = makeStore()
        await store.restore(historicalUtterances: [])
        let result = await store.current()
        XCTAssertNil(result)
    }

    func test_summarizeFailure_confirmsChunkAsRawText() async {
        let (store, repository) = makeStore()
        await repository.setShouldThrowOnSummarize(true)
        for i in 0..<10 {
            await store.add(String(repeating: "\(i)", count: 100))
        }

        let result = await store.current()

        XCTAssertNotNil(result, "요약 실패해도 압축본 생성 자체는 실패하면 안 됨(원문으로 대체)")
    }
}

private extension MockSummaryRepository {
    func setShouldThrowOnSummarize(_ value: Bool) {
        shouldThrowOnSummarize = value
    }
}
