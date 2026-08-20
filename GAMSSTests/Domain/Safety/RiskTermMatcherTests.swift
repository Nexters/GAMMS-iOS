//
//  RiskTermMatcherTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

import XCTest
@testable import GAMSS

final class RiskTermMatcherTests: XCTestCase {
    private let matcher = RiskTermMatcher()

    private let lexicon = RiskLexicon(
        version: 1,
        terms: [
            RiskTerm(term: "자살", level: .critical),
            RiskTerm(term: "죽고싶", level: .critical),
            RiskTerm(term: "살기싫", level: .warning),
            RiskTerm(term: "관찰만하는단어", level: .none),
        ],
        safePhrases: ["배고파죽", "죽고싶지않", "자살예방"],
        agencies: [
            SupportAgency(id: "a", name: "자살예방 상담전화", description: "24시간 무료 전문 상담", phoneNumber: "109", url: nil, priority: 1, isEmergency: false),
            SupportAgency(id: "b", name: "청소년 상담전화", description: "청소년 전문 상담", phoneNumber: "1388", url: nil, priority: 3, isEmergency: false),
        ]
    )

    func test_match_noRiskTerms_returnsNone() {
        XCTAssertEqual(matcher.match(text: "오늘은 날씨가 좋아서 오래 산책했다", lexicon: lexicon).level, .none)
    }

    func test_match_criticalTerm_returnsCritical() {
        XCTAssertEqual(matcher.match(text: "자살에 대해 계속 생각한다", lexicon: lexicon).level, .critical)
    }

    func test_match_warningTermOnly_returnsWarning() {
        XCTAssertEqual(matcher.match(text: "요즘은 그냥 살기싫다", lexicon: lexicon).level, .warning)
    }

    func test_match_criticalAndWarningTogether_returnsCritical() {
        XCTAssertEqual(matcher.match(text: "살기싫고 죽고싶다", lexicon: lexicon).level, .critical)
    }

    func test_match_idiomaticPhrase_returnsNone() {
        XCTAssertEqual(matcher.match(text: "배고파 죽겠다", lexicon: lexicon).level, .none)
    }

    func test_match_negatedExpression_returnsNone() {
        XCTAssertEqual(matcher.match(text: "죽고 싶지 않아", lexicon: lexicon).level, .none)
    }

    func test_match_safeCompoundWord_returnsNone() {
        XCTAssertEqual(matcher.match(text: "학교에서 자살예방 교육을 들었다", lexicon: lexicon).level, .none)
    }

    func test_match_splitBySpacingOrPunctuation_stillDetects() {
        XCTAssertEqual(matcher.match(text: "자 살", lexicon: lexicon).level, .critical)
        XCTAssertEqual(matcher.match(text: "죽.고.싶.다", lexicon: lexicon).level, .critical)
    }

    func test_match_shortTermCrossingWordBoundary_returnsNone() {
        XCTAssertEqual(matcher.match(text: "과자 살까 말까 고민했다", lexicon: lexicon).level, .none)
        XCTAssertEqual(matcher.match(text: "혼자 살아보니 편하다", lexicon: lexicon).level, .none)
    }

    func test_match_longTermIgnoresWordBoundary_returnsCritical() {
        XCTAssertEqual(matcher.match(text: "요즘죽고싶다", lexicon: lexicon).level, .critical)
    }

    func test_match_termWithNoneLevel_returnsNone() {
        XCTAssertEqual(matcher.match(text: "관찰만하는단어", lexicon: lexicon).level, .none)
    }

    func test_match_emptyOrWhitespaceInput_returnsNone() {
        XCTAssertEqual(matcher.match(text: "", lexicon: lexicon).level, .none)
        XCTAssertEqual(matcher.match(text: "   \n  ", lexicon: lexicon).level, .none)
    }

    func test_match_whenDetected_returnsLexiconAgencies() {
        let detection = matcher.match(text: "자살", lexicon: lexicon)
        XCTAssertEqual(detection.agencies.map(\.name), ["자살예방 상담전화", "청소년 상담전화"])
    }

    func test_shouldBlock_onlyTrueForCritical() {
        XCTAssertTrue(matcher.match(text: "죽고싶다", lexicon: lexicon).shouldBlock)
        XCTAssertFalse(matcher.match(text: "살기싫다", lexicon: lexicon).shouldBlock)
        XCTAssertFalse(matcher.match(text: "평범한 하루였다", lexicon: lexicon).shouldBlock)
    }
}
