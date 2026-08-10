//
//  SendMessageValidationError.swift
//  GAMSS
//
//  Created by cchanmi on 8/10/26.
//

import Foundation

/// `SendMessageUseCase`가 네트워크로 나가기 직전에 검증하는 최종 규칙 위반.
/// ViewModel의 입력 제한은 UX용이고, 실제로 신뢰해야 할 기준은 여기다.
enum SendMessageValidationError: Error {
    case empty
    case tooLong
}

extension SendMessageValidationError: Equatable {}

extension SendMessageValidationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .empty:
            return "메시지를 입력해주세요."
        case .tooLong:
            return "메시지가 너무 길어요."
        }
    }
}
