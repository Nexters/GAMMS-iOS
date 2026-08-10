//
//  ConversationSummaryStore.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import Foundation

protocol ConversationSummaryStore {
    /// 전송 성공 후에만 호출한다. 화면 갱신 뒤, 비동기로(블로킹 없이) 호출해야 한다.
    func add(_ utterance: String) async
    /// 다음 전송 직전에 호출한다. 아직 압축할 게 없으면 nil(= 요청 필드 생략).
    func current() async -> String?
    func reset() async
    /// 재진입 복원 전용. 히스토리 발화를 요약 없이 원문 그대로 채워 넣는다 — 절대 이 발화들에
    /// 대해 summarize()를 호출하지 않는다(발화 수에 비례해 느려지는 것 방지).
    func restore(historicalUtterances: [String]) async
}

/// 압축본 = 첫 발화 원문 + 확정 청크들 + 최근 발화 원문. 첫 발화는 주제를, 최근 발화는 답글이
/// 이어받는 맥락을 붙들고 있어 원문으로 남긴다. 그 사이만 요약하고, 한 번 확정한 청크는 다시
/// 요약하지 않는다(요약의 요약을 피한다).
///
/// 압축은 부가 기능이라 실패해도 전송·조회를 막지 않는다.
///
/// 가변 상태를 들고 있어 대화 하나에 인스턴스 하나여야 한다. 여러 대화에 공유하면 내용이 섞인다.
actor DefaultConversationSummaryStore: ConversationSummaryStore {
    private let summaryRepository: SummaryRepository

    private var utterances: [String] = []
    /// 요약본이거나, 요약이 실패했으면 원문이다.
    private var closedChunks: [String] = []
    private var pendingChunk: [String] = []
    private var pendingChunkTokens = 0
    /// 첫 발화는 원문으로 남으므로 청크 대상에서 제외한다.
    private var nextChunkCandidate = 1

    init(summaryRepository: SummaryRepository) {
        self.summaryRepository = summaryRepository
    }

    func add(_ utterance: String) async {
        let trimmed = utterance.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        utterances.append(trimmed)
        await closeChunksIfNeeded()
    }

    /// 보낼 압축본. 아직 압축할 게 없으면 nil.
    func current() async -> String? {
        guard !utterances.isEmpty else { return nil }

        let recentStart = recentStart()
        // 첫 발화와 최근 발화는 상한 안에서 항상 살린다.
        let anchorHead = recentStart > 0 ? [utterances[0]] : []
        let anchorTail = Array(utterances[recentStart...])
        let middle = closedChunks + pendingChunk

        let anchorLength = joinedLength(anchorHead + anchorTail)
        let kept = takeNewestFitting(middle, budget: ConversationSummaryPolicy.maxContextSummaryLength - anchorLength)

        let result = (anchorHead + kept + anchorTail).joined(separator: Self.separator)
        return String(result.prefix(ConversationSummaryPolicy.maxContextSummaryLength))
    }

    func reset() async {
        utterances.removeAll()
        closedChunks.removeAll()
        pendingChunk.removeAll()
        pendingChunkTokens = 0
        nextChunkCandidate = 1
    }

    /// 재진입 복원: 요약을 절대 돌리지 않는다. 중간 구간(첫 발화 다음부터 최근창 시작 직전까지)을
    /// 원문 그대로 확정 청크 하나로 넣고, 다음 후보 인덱스를 최근창 시작으로 옮겨 재청킹을 막는다.
    func restore(historicalUtterances: [String]) async {
        await reset()
        guard !historicalUtterances.isEmpty else { return }

        utterances = historicalUtterances
        let recentStart = recentStart()
        if recentStart > 1 {
            closedChunks = [utterances[1..<recentStart].joined(separator: Self.separator)]
        }
        // 첫 발화(인덱스 0)는 항상 청크 후보에서 제외되어야 한다. recentStart가 0 또는 1이면
        // (발화가 3개 이하로 복원된 경우) 그대로 대입하면 후보 인덱스가 0이 되어 첫 발화가
        // 다음 add()에서 청크 대상으로 잘못 편입된다 — 최소 1로 바닥을 둔다.
        nextChunkCandidate = max(recentStart, 1)
    }

    private func recentStart() -> Int {
        max(utterances.count - ConversationSummaryPolicy.recentRawUtterances, 0)
    }

    private func closeChunksIfNeeded() async {
        let recentStart = recentStart()
        while nextChunkCandidate < recentStart {
            let utterance = utterances[nextChunkCandidate]
            let tokens = await countTokens(utterance)

            // (a) 넘기기 전에 끊는다 — 예산을 넘겨서 요약하면 요약기 입력 한계에서 초과분이
            // 잘려 사라진다.
            if !pendingChunk.isEmpty && pendingChunkTokens + tokens > ConversationSummaryPolicy.summaryChunkTokenBudget {
                await closePendingChunk()
            }

            pendingChunk.append(utterance)
            pendingChunkTokens += tokens
            nextChunkCandidate += 1

            // (b) 정확히 찼으면 즉시 확정
            if pendingChunkTokens >= ConversationSummaryPolicy.summaryChunkTokenBudget {
                await closePendingChunk()
            }
        }
    }

    /// 요약 실패 시 원문으로 확정한다. 열어 두면 전송마다 같은 요약을 재시도해 지연이 누적된다.
    private func closePendingChunk() async {
        guard !pendingChunk.isEmpty else { return }
        let text = pendingChunk.joined(separator: Self.separator)
        // 발화 하나가 예산보다 크면 요약해도 잘리므로 원문으로 둔다.
        let overBudget = pendingChunkTokens > ConversationSummaryPolicy.summaryChunkTokenBudget
        let summarized = overBudget ? nil : (try? await summaryRepository.summarize(text: text))
        closedChunks.append(summarized ?? text)
        pendingChunk.removeAll()
        pendingChunkTokens = 0
    }

    /// 토크나이저가 죽으면 글자 수로 센다. 실제 토큰 수의 상한이라 예산을 넘기지 않는다.
    private func countTokens(_ utterance: String) async -> Int {
        (try? await summaryRepository.countTokens(text: utterance)) ?? utterance.count
    }

    /// 예산에 맞을 때까지 오래된 항목부터 버리고 원래 순서로 돌려준다.
    private func takeNewestFitting(_ parts: [String], budget: Int) -> [String] {
        guard budget > 0 else { return [] }
        var remaining = budget
        var kept: [String] = []
        for part in parts.reversed() {
            let cost = part.count + Self.separator.count
            guard cost <= remaining else { break }
            remaining -= cost
            kept.insert(part, at: 0)
        }
        return kept
    }

    private func joinedLength(_ parts: [String]) -> Int {
        parts.reduce(0) { $0 + $1.count + Self.separator.count }
    }

    private static let separator = " "
}
