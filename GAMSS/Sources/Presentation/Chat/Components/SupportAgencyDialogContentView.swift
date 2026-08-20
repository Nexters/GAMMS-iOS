//
//  SupportAgencyDialogContentView.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

import SwiftUI

struct SupportAgencyDialogContentView: View {
    let detection: RiskDetection
    let onDismiss: () -> Void

    var body: some View {
        ModalContentView(
            title: "혼자 감당하지 않아도 괜찮아요.",
            subtitle: "대화에서 도움이 필요하다는 신호가 확인됐어요.\n전문가와 이야기해 보는 걸 추천드려요.",
            actions: [.init(title: "닫기", style: .primary, action: onDismiss)]
        ) {
            VStack(alignment: .leading, spacing: Spacing.spacing200) {
                ForEach(detection.agencies) { agency in
                    SupportAgencyRow(agency: agency)
                }

                HStack(spacing: Spacing.spacing050) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(Color.colorGray500)
                    Text("24시간 상담이 가능해요, 누르면 바로 연결돼요.")
                        .typography(.caption3)
                        .foregroundStyle(Color.colorGray500)
                }
            }
            .padding(Spacing.spacing200)
            .background(Color.colorGray075)
            .clipShape(RoundedRectangle(cornerRadius: Radius.radius200))
            .padding(.top, Spacing.spacing200)
            .padding(.bottom, Spacing.spacing200)
        }
    }
}

#Preview {
    SupportAgencyDialogContentView(
        detection: RiskDetection(
            level: .critical,
            agencies: [
                SupportAgency(id: "a", name: "종합 상담센터", description: "", phoneNumber: "129", url: nil, priority: 1, isEmergency: false),
                SupportAgency(id: "b", name: "자살예방 상담", description: "", phoneNumber: "109", url: nil, priority: 2, isEmergency: false),
                SupportAgency(id: "c", name: "긴급 도움이 필요해요", description: "", phoneNumber: "119", url: nil, priority: 5, isEmergency: true),
            ]
        ),
        onDismiss: {}
    )
    .padding(.horizontal, 28)
    .background(Color.colorGray100)
}
