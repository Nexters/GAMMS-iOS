//
//  EmotionAnalysisError.swift
//  GAMSS
//
//  Created by cchanmi on 7/24/26.
//

enum EmotionAnalysisError: Error, Equatable {
    case emptyInput
    case modelLoadFailed
    case inferenceFailed
}
