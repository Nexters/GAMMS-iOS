//
//  ScrollDownButtonView.swift
//  GAMSS
//
//  Created by cchanmi on 8/18/26.
//

import SwiftUI

struct ScrollDownButtonView: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image("scrollDownButton")
        }
        .accessibilityLabel("최하단으로 이동")
    }
}

#Preview {
    ScrollDownButtonView(action: {})
        .padding()
}
