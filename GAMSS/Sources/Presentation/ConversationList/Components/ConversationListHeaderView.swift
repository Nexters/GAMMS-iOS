//
//  ConversationListHeaderView.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import SwiftUI

struct ConversationListHeaderView: View {
    var currentMode: ConversationMode
    var onTappedBackButton: (() -> Void)?
    
    var body: some View {
        HStack(spacing: Spacing.spacing200) {
            switch currentMode {
            case .normal:
                Image("logoGamss")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
            case .delete:
                Button {
                    onTappedBackButton?()
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.colorGray900)
                }
            }

            Spacer()

            Image(systemName: "magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.colorGray500)

            Image(.homeMenuIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.colorGray500)
        }
    }
}
