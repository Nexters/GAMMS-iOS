//
//  ModalButtonStyle.swift
//  GAMSS
//
//  Created by 이건준 on 8/14/26.
//

import SwiftUI

enum ModalButtonStyle {
    case secondary
    case primary
    case destructive
    
    var foregroundColor: Color {
        switch self {
        case .secondary:
            return .colorGray600
        case .primary:
            return .colorWhite
        case .destructive:
            return .colorWhite
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .secondary:
            return .colorGray100
        case .primary:
            return .colorGray950
        case .destructive:
            return .colorRed
        }
    }
}
