//
//  SettingView.swift
//  GAMSS
//
//  Created by LEEGEONJUN on 8/12/26.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, Spacing.spacing300)
                .padding(.top, Spacing.spacing300)
                .padding(.bottom, Spacing.spacing500)
            
            VStack(spacing: 0) {
                ForEach(SettingSection.allCases) { section in
                    ForEach(section.items) { item in
                        SettingListItemView(item: item)
                            .padding(.horizontal, 18)
                        
                        if item.showsDividerBelow {
                            fullWidthDivider
                        }
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.colorWhite)
        .navigationBarHidden(true)
    }
    
    private var header: some View {
        Image(.logoGamss)
            .resizable()
            .scaledToFit()
            .frame(height: 24)
    }
    
    private var fullWidthDivider: some View {
        Color.colorGray075
            .frame(height: 2)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        SettingView()
    }
}
