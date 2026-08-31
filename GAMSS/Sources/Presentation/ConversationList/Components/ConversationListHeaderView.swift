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
    var onTappedSettingButton: (() -> Void)?
    
    var body: some View {
        NavigationBarView(
            leading: currentMode == .normal ? .logo : .backButton,
            onBack: { onTappedBackButton?() }
        ) {
            HStack(spacing: Spacing.spacing200) {
                Button {
                    onTappedSearchButton?()
                } label: {
                    Image(systemName: "magnifyingglass")
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.colorGray900)
                }
                
                Button {
                    onTappedSettingButton?()
                } label: {
                    Image("gear")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.colorGray900)
                }
            }
        }
    }
}
