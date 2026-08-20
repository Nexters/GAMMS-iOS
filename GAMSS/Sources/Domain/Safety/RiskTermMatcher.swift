//
//  RiskTermMatcher.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

import Foundation

struct RiskTermMatcher {
    private static let mask: Character = " "
    private static let shortTermLength = 2

    func match(text: String, lexicon: RiskLexicon) -> RiskDetection {
        let matched = matchedTerms(in: text, lexicon: lexicon)
        guard !matched.isEmpty else { return .none }
        return RiskDetection(level: level(of: matched), agencies: lexicon.agencies)
    }

    private func level(of matched: [RiskTerm]) -> RiskLevel {
        matched.contains { $0.level == .critical } ? .critical : .warning
    }

    private func matchedTerms(in text: String, lexicon: RiskLexicon) -> [RiskTerm] {
        let normalized = Self.normalize(text)
        guard !normalized.value.isEmpty else { return [] }
        let masked = maskSafePhrases(normalized.value, safePhrases: lexicon.safePhrases)
        return lexicon.terms.filter { matches($0, maskedText: masked, wordStarts: normalized.wordStarts) }
    }

    private func matches(_ term: RiskTerm, maskedText: String, wordStarts: Set<Int>) -> Bool {
        guard term.level != .none else { return false }
        let normalizedTerm = Self.normalize(term.term).value
        guard !normalizedTerm.isEmpty else { return false }
        if normalizedTerm.count > Self.shortTermLength {
            return maskedText.contains(normalizedTerm)
        }
        return occurrences(of: normalizedTerm, in: maskedText).contains { wordStarts.contains($0) }
    }

    private struct NormalizedText {
        let value: String
        let wordStarts: Set<Int>
    }

    private static func normalize(_ text: String) -> NormalizedText {
        var value = ""
        var wordStarts = Set<Int>()
        var atWordStart = true
        for character in text.precomposedStringWithCompatibilityMapping {
            if character.isLetter || character.isNumber {
                if atWordStart { wordStarts.insert(value.count) }
                value += character.lowercased()
                atWordStart = false
            } else {
                atWordStart = true
            }
        }
        return NormalizedText(value: value, wordStarts: wordStarts)
    }

    private func maskSafePhrases(_ normalized: String, safePhrases: [String]) -> String {
        safePhrases.reduce(normalized) { text, phrase in
            let normalizedPhrase = Self.normalize(phrase).value
            guard !normalizedPhrase.isEmpty else { return text }
            let mask = String(repeating: Self.mask, count: normalizedPhrase.count)
            return text.replacingOccurrences(of: normalizedPhrase, with: mask)
        }
    }

    private func occurrences(of value: String, in text: String) -> [Int] {
        var positions: [Int] = []
        var searchStart = text.startIndex
        while let range = text.range(of: value, range: searchStart..<text.endIndex) {
            positions.append(text.distance(from: text.startIndex, to: range.lowerBound))
            searchStart = text.index(after: range.lowerBound)
        }
        return positions
    }
}
