//
//  CardView.swift
//  GAMSS
//
//  Created by cchanmi on 8/17/26.
//

import SwiftUI

struct CardView<BottomContent: View>: View {
    let card: Card
    @ViewBuilder let bottomContent: () -> BottomContent

    private let cardSize = CGSize(width: 342, height: 505)
    private let illustrationSize = CGSize(width: 270, height: 156)

    var body: some View {
        ZStack {
            Image("cardPaperBackground")
                .resizable()
                .frame(width: cardSize.width, height: cardSize.height)

            VStack(spacing: 0) {
                Text(ConversationListDateHeaderFormatter.string(from: card.date))
                    .typography(.subtitle3)
                    .foregroundStyle(Color.colorGray900)

                Spacer().frame(height: Spacing.spacing350)

                emotionIllustration

                Spacer().frame(height: Spacing.spacing350)

                DashedDivider()

                Spacer().frame(height: Spacing.spacing500)

                VStack(spacing: Spacing.spacing200) {
                    Text(card.emotion?.cardTitle ?? "오늘 하루를 기록했어요")
                        .typography(.title2)
                        .foregroundStyle(Color.colorGray950)
                        .multilineTextAlignment(.center)

                    Text(card.message)
                        .typography(.body4Regular)
                        .foregroundStyle(Color.colorGray800)
                        .multilineTextAlignment(.center)
                }

                Spacer().frame(height: Spacing.spacing500)

                DashedDivider()

                Spacer().frame(height: 29)

                bottomContent()

                Spacer(minLength: 0)
            }
            .padding(.horizontal, Spacing.spacing400)
            .padding(.vertical, Spacing.spacing500)
            .frame(width: cardSize.width, height: cardSize.height)
        }
        .frame(width: cardSize.width, height: cardSize.height)
    }

    @ViewBuilder
    private var emotionIllustration: some View {
        if let emotion = card.emotion {
            Image(CardResultViewModel.illustrationImageName(for: emotion))
                .resizable()
                .scaledToFit()
                .frame(width: illustrationSize.width, height: illustrationSize.height)
        } else {
            RoundedRectangle(cornerRadius: Radius.radius200)
                .fill(Color.colorGray025)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.radius200)
                        .strokeBorder(Color.colorGray300, lineWidth: 1)
                )
                .overlay(
                    Text("감정")
                        .typography(.body4Medium)
                        .foregroundStyle(Color.colorGray950)
                )
                .frame(width: illustrationSize.width, height: illustrationSize.height)
        }
    }
}

private struct DashedDivider: View {
    var body: some View {
        DashedLine()
            .stroke(Color.colorGray950, style: StrokeStyle(lineWidth: 1.3, dash: [5]))
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
    ZStack {
        Color.colorBlack.opacity(0.7).ignoresSafeArea()
        CardView(
            card: Card(id: 1, conversationId: 1, emotion: .anger, summary: "오늘 비가 와서 짜증나고 찝찝하다", message: "얘 오늘 건들면 안 됨.", date: Date())
        ) {
            EmptyView()
        }
    }
}
