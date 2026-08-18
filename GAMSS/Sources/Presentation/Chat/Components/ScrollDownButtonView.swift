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
            Image(systemName: "chevron.down")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.colorWhite)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.colorGray900))
        }
        .accessibilityLabel("최하단으로 이동")
    }
}

#Preview {
    ScrollDownButtonView(action: {})
        .padding()
}
