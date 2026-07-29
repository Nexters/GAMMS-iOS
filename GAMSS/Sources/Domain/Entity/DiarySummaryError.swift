//
//  DiarySummaryError.swift
//  GAMSS
//
//  Created by cchanmi on 7/29/26.
//

import Foundation

enum DiarySummaryError: Error {
    case modelLoadFailed(underlying: Error? = nil)
    case inferenceFailed(underlying: Error? = nil)
}

extension DiarySummaryError: Equatable {
    static func == (lhs: DiarySummaryError, rhs: DiarySummaryError) -> Bool {
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

extension DiarySummaryError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .modelLoadFailed:
            return "요약 모델을 불러오지 못했어요."
        case .inferenceFailed:
            return "요약을 생성하지 못했어요."
        }
    }
}
