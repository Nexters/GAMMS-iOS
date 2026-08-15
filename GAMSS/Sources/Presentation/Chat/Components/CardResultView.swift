//
//  CardResultView.swift
//  GAMSS
//
//  Created by cchanmi on 8/15/26.
//

import SwiftUI

/// 대화 종료 후 생성된 카드를 보여주는 결과 팝업. 종이 질감/손그림 테두리 같은 최종 비주얼은
/// 디자인 자산이 준비되면 다음 이터레이션에서 적용하고, 이번엔 기존 디자인 시스템 색/라운딩으로
/// 기능 위주로만 구현한다.
struct CardResultView: View {
    let card: Card
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.colorGray950.opacity(0.4)
                .ignoresSafeArea()

            ZStack(alignment: .topTrailing) {
                cardContent

                closeButton
                    .padding(Spacing.spacing300)
            }
            .padding(.horizontal, Spacing.spacing400)
        }
    }

    private var cardContent: some View {
        VStack(spacing: Spacing.spacing300) {
            Text(ConversationListDateHeaderFormatter.string(from: card.date))
                .typography(.subtitle3)
                .foregroundStyle(Color.colorGray950)

            emotionIcon

            DashedDivider()

            VStack(spacing: Spacing.spacing150) {
                Text(card.message)
                    .typography(.title3)
                    .foregroundStyle(Color.colorGray950)
                    .multilineTextAlignment(.center)

                Text(card.summary)
                    .typography(.body4Regular)
                    .foregroundStyle(Color.colorGray700)
                    .multilineTextAlignment(.center)
            }

            DashedDivider()

            Text("이야기했던 감정들을 카드로 만들었어요")
                .typography(.body5Regular)
                .foregroundStyle(Color.colorGray500)

            confirmButton
        }
        .padding(Spacing.spacing400)
        .background(Color.colorWhite)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.radius200)
                .strokeBorder(Color.colorGray950, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.radius200))
    }

    /// 실제 캐릭터 일러스트 에셋이 전달되기 전까지는 감정 이름을 적은 원으로 대체한다.
    private var emotionIcon: some View {
        Circle()
            .fill(Color.colorGray025)
            .overlay(Circle().strokeBorder(Color.colorGray950, lineWidth: 1))
            .overlay(
                Text(card.emotion?.displayName ?? "감정")
                    .typography(.body5Medium)
                    .foregroundStyle(Color.colorGray950)
            )
            .frame(width: 88, height: 88)
    }

    private var closeButton: some View {
        Button(action: onConfirm) {
            Image(systemName: "xmark")
                .foregroundStyle(Color.colorGray950)
        }
        .accessibilityLabel("닫기")
    }

    private var confirmButton: some View {
        Button(action: onConfirm) {
            Text("확인")
                .typography(.subtitle3)
                .foregroundStyle(Color.colorGray025)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.spacing200)
                .background(
                    RoundedRectangle(cornerRadius: Radius.radius200)
                        .fill(Color.colorGray900)
                )
        }
    }
}

private struct DashedDivider: View {
    var body: some View {
        DashedLine()
            .stroke(Color.colorGray300, style: StrokeStyle(lineWidth: 1, dash: [4]))
            .frame(height: 1)
    }
}

private struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

#Preview {
    CardResultView(
        card: Card(id: 1, conversationId: 1, emotion: .anger, summary: "오늘 비가 와서 짜증나고 찝찝하다", message: "얘 오늘 건들면 안 됨.", date: Date()),
        onConfirm: {}
    )
}
