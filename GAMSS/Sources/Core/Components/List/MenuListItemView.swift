//
//  MenuListItemView.swift
//  GAMSS
//
//  Created by LEEGEONJUN on 8/13/26.
//

import SwiftUI

struct MenuListItemView: View {
    let title: String
    var titleColor: Color = .colorGray950
    var badgeText: String?
    var trailingText: String?
    var trailingColor: Color = .colorGray500
    
    var body: some View {
        HStack(spacing: Spacing.spacing100) {
            Text(title)
                .typography(.body3Medium)
                .foregroundStyle(titleColor)
            
            if let badgeText {
                badge(badgeText)
            }
            
            Spacer(minLength: 0)
            
            if let trailingText {
                Text(trailingText)
                    .typography(.body3Medium)
                    .foregroundStyle(trailingColor)
            }
        }
        .frame(height: 40)
        .padding(.vertical, Spacing.spacing200)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
    
    private func badge(_ text: String) -> some View {
        Text(text)
            .typography(.body6Medium)
            .foregroundStyle(Color.colorGray900)
            .padding(.horizontal, Spacing.spacing075)
            .padding(.vertical, Spacing.spacing025)
            .background(Color.colorGray200)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 0) {
        MenuListItemView(title: "계정 정보")
        MenuListItemView(title: "알림 설정", badgeText: "OFF")
        MenuListItemView(title: "앱 버전", trailingText: "0.0.1")
        MenuListItemView(title: "회원탈퇴", titleColor: .colorRed)
    }
    .padding(.horizontal, 18)
}
