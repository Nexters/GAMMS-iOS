//
//  ModalAction.swift
//  GAMSS
//
//  Created by 이건준 on 8/14/26.
//

import Foundation

struct ModalAction {
    let title: String
    let style: ModalButtonStyle
    let action: () -> Void

    init(
        title: String,
        style: ModalButtonStyle,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.action = action
    }
}
