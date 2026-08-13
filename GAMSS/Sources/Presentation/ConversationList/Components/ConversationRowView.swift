//
//  ConversationRowView.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import SwiftUI

/// 대화방 목록의 카드 한 장. 좌측엔 미리보기 텍스트(대화방 title — 사용자가 대화를 처음 시작할 때
/// 보낸 문장이 서버에 title로 저장된다, 25자 초과 시 말줄임), 우측엔 생성 시각을 보여준다.
struct ConversationRowView: View {
    let conversation: ConversationSummary

    var body: some View {
        HStack(spacing: Spacing.spacing200) {
            Text(ConversationPreviewTextFormatter.truncated(conversation.title ?? "제목 없음"))
                .typography(.body4Medium)
                .foregroundStyle(Color.colorGray950)
                .lineLimit(1)

            Spacer(minLength: Spacing.spacing200)

            Text(MessageTimestampFormatter.string(from: conversation.createdAt))
                .typography(.body5Regular)
                .foregroundStyle(Color.colorGray600)
        }
        .padding(Spacing.spacing200)
        .background(
            RoundedRectangle(cornerRadius: Radius.radius200)
                .fill(Color.colorGray025)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.radius200)
                .strokeBorder(Color.colorGray950, lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: Spacing.spacing100) {
        ConversationRowView(conversation: ConversationSummary(id: 1, title: "너무졸려서 지하철에서 강 놓고싶었어", status: "ACTIVE", createdAt: Date()))
        ConversationRowView(conversation: ConversationSummary(id: 2, title: "부장이랑 싸웠는데 밥도 맛없는 거 먹은 날날날날 정말정말 길게 쓰면 잘리는지 확인용 텍스트", status: "ACTIVE", createdAt: Date()))
        ConversationRowView(conversation: ConversationSummary(id: 3, title: nil, status: "ACTIVE", createdAt: Date()))
    }
    .padding(Spacing.spacing400)
}
