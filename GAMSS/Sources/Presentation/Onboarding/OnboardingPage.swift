//
//  OnboardingPage.swift
//  GAMSS
//
//  Created by LEEGEONJUN on 8/14/26.
//

import SwiftUI

enum OnboardingPage: Int, CaseIterable, Identifiable {
    case talk
    case emotions
    case empty
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .talk:
            "누구한테 말 못할 말이 있다면\n이야기해보세요"
        case .emotions:
            "6가지의 감정 친구들과\n이야기를 이어가보세요"
        case .empty:
            "안좋았던 감정을\n비워보세요"
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .talk, .emotions:
            "다음"
        case .empty:
            "시작하기"
        }
    }
    
    var buttonColor: Color {
        switch self {
        case .talk, .emotions:
            .colorGray950
        case .empty:
            .colorApricot
        }
    }
    
    var showsBackButton: Bool {
        self != .talk
    }
    
    var showsSkipButton: Bool {
        self != .empty
    }
    
    var backgroundImage: Image {
        switch self {
        case .talk:
            return Image(.thoughtNotes)
        case .emotions:
            return Image(.emotions)
        case .empty:
            return Image(.thoughtNotesDiscard)
        }
    }
}
