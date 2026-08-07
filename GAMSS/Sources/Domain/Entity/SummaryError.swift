//
//  SummaryError.swift
//  GAMSS
//

import Foundation

enum SummaryError: Error {
    case modelLoadFailed(underlying: Error? = nil)
    case inferenceFailed(underlying: Error? = nil)
}

extension SummaryError: Equatable {
    static func == (lhs: SummaryError, rhs: SummaryError) -> Bool {
        switch (lhs, rhs) {
        case (.modelLoadFailed, .modelLoadFailed):
            return true
        case (.inferenceFailed, .inferenceFailed):
            return true
        default:
            return false
        }
    }
}

extension SummaryError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .modelLoadFailed:
            return "요약 모델을 불러오지 못했어요."
        case .inferenceFailed:
            return "요약을 생성하지 못했어요."
        }
    }
}
