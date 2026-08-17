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
    var onTappedSearchButton: (() -> Void)?
    
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
                        .foregroundStyle(Color.colorGray900)
                }
            }
            
            Spacer()
            
            Button {
                onTappedSearchButton?()
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.colorGray900)
            }
            
            Image(.homeMenuIcon)
                .foregroundStyle(Color.colorGray900)
        }
        .padding(.vertical, Spacing.spacing400)
    }
}
