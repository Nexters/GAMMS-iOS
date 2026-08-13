//
//  ConversationListEmptyView.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import SwiftUI

/// 오늘 생성된 대화방이 없을 때 리스트 영역에 표시하는 안내 문구.
struct ConversationListEmptyView: View {
    var body: some View {
        Text("아직 나눈 대화가 없어요")
            .typography(.body3Regular)
            .foregroundStyle(Color.colorGray500)
            .frame(maxWidth: .infinity)
            .padding(.top, Spacing.spacing800)
    }
}

#Preview {
    ConversationListEmptyView()
}
