//
//  CustomTabBar.swift
//  GAMSS
//
//  Created by cchanmi on 8/10/26.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.top, Spacing.spacing200)
        .padding(.bottom, Spacing.spacing100)
        .background(Color.colorWhite)
        .overlay(
            Rectangle()
                .stroke(Color.colorBlack, lineWidth: 1.5)
        )
    }

    @ViewBuilder
    private func tabButton(for tab: MainTab) -> some View {
        let isSelected = selectedTab == tab

        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: Spacing.spacing050) {
                Image(tab.iconName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text(tab.title)
                    .typography(.caption3)
            }
            .foregroundStyle(isSelected ? Color.colorGray950 : Color.colorGray300)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(.home))
            .padding(.horizontal, Spacing.spacing400)
            .padding(.bottom, Spacing.spacing200)
    }
}
