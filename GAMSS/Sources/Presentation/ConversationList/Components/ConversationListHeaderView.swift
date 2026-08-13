//
//  ConversationListHeaderView.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import SwiftUI

/// 대화방 목록 화면 상단 네비게이션. 로고 + 검색 아이콘 + 햄버거 아이콘, 둘 다 자리만 차지하고
/// 숨김 처리(`.hidden()`). 검색/메뉴 기능은 이번 범위에서 구현하지 않는다.
struct ConversationListHeaderView: View {
    var body: some View {
        HStack(spacing: Spacing.spacing200) {
            Image("logoGamss")
                .resizable()
                .scaledToFit()
                .frame(height: 24)

            Spacer()

            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.colorGray500)
                .hidden()

            Image(systemName: "line.3.horizontal")
                .foregroundStyle(Color.colorGray500)
                .hidden()
        }
    }
}

#Preview {
    ConversationListHeaderView()
        .padding(Spacing.spacing400)
}
