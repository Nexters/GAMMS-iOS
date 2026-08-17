//
//  OutlineButton.swift
//  GAMSS
//
//  Created by cchanmi on 8/17/26.
//

import SwiftUI

struct OutlineButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .typography(.subtitle4)
                .foregroundStyle(Color.colorGray950)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.radius100)
                        .strokeBorder(Color.colorGray900, lineWidth: 1.5)
                )
        }
    }
}

#Preview {
    HStack(spacing: Spacing.spacing100) {
        OutlineButton(title: "기록 버리기") {}
        OutlineButton(title: "대화보기") {}
    }
    .padding()
}
