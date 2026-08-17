//
//  CardResultView.swift
//  GAMSS
//
//  Created by cchanmi on 8/15/26.
//

import SwiftUI

struct CardResultView: View {
    let card: Card
    let onComplete: () -> Void

    @StateObject private var viewModel: CardResultViewModel

    init(card: Card, viewModel: CardResultViewModel, onComplete: @escaping () -> Void) {
        self.card = card
        self.onComplete = onComplete
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private let cardSize = CGSize(width: 342, height: 505)
    private let illustrationSize = CGSize(width: 270, height: 156)
    private let foldGuideSize = CGSize(width: 190, height: 68)
    private let foldStepOneSize = CGSize(width: 353, height: 273)
    private let foldStepTwoSize = CGSize(width: 237, height: 253)
    private let discardArrowSize = CGSize(width: 101, height: 209)
    private let trashBinSize = CGSize(width: 402, height: 232)

    var body: some View {
        ZStack {
            Color.colorBlack.opacity(0.7)
                .ignoresSafeArea()

            switch viewModel.stage {
            case .unfolded:
                cardContent
            case .foldedOnce:
                foldStepImage("cardFoldStepOne", size: foldStepOneSize)
            case .foldedTwice:
                foldStepImage("cardFoldStepTwo", size: foldStepTwoSize)
            case .readyToDiscard:
                discardableCard
            }
        }
    }

    private var cardContent: some View {
        ZStack(alignment: .topTrailing) {
            Image("cardPaperBackground")
                .resizable()
                .frame(width: cardSize.width, height: cardSize.height)

            VStack(spacing: 0) {
                Text(ConversationListDateHeaderFormatter.string(from: card.date))
                    .typography(.subtitle3)
                    .foregroundStyle(Color.colorGray950)

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

                foldGuideButton

                Spacer(minLength: 0)
            }
            .padding(.horizontal, Spacing.spacing400)
            .padding(.vertical, Spacing.spacing500)
            .frame(width: cardSize.width, height: cardSize.height)

            closeButton
                .padding(Spacing.spacing300)
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

    private var closeButton: some View {
        Button(action: onComplete) {
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.colorGray950)
        }
        .accessibilityLabel("닫기")
    }

    private var foldGuideButton: some View {
        Button(action: viewModel.advanceStage) {
            Image("cardFoldGuide")
                .resizable()
                .frame(width: foldGuideSize.width, height: foldGuideSize.height)
        }
        .accessibilityLabel("종이를 눌러 2번 접어주세요")
    }

    private func foldStepImage(_ imageName: String, size: CGSize) -> some View {
        Button(action: viewModel.advanceStage) {
            Image(imageName)
                .resizable()
                .frame(width: size.width, height: size.height)
        }
        .accessibilityLabel("종이 접기")
    }

    private var discardableCard: some View {
        ZStack {
            trashBin
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(edges: .bottom)

            Color.clear
                .frame(width: foldStepTwoSize.width, height: foldStepTwoSize.height)
                .overlay(alignment: .top) {
                    Text("내려서 버려주세요")
                        .typography(.body3Medium)
                        .foregroundStyle(Color.colorWhite)
                        .fixedSize()
                        .alignmentGuide(.top) { $0[.bottom] + 29 }
                }

            Image("cardFoldStepTwo")
                .resizable()
                .frame(width: foldStepTwoSize.width, height: foldStepTwoSize.height)
                .overlay(alignment: .top) {
                    Image("cardDiscardArrow")
                        .resizable()
                        .frame(width: discardArrowSize.width, height: discardArrowSize.height)
                        .offset(y: 104)
                }
                .offset(y: viewModel.dragOffset)
                .opacity(CardResultViewModel.opacity(forDragOffset: viewModel.dragOffset))
                .gesture(discardDragGesture)
        }
    }

    private var trashBin: some View {
        Image("cardTrashBin")
            .resizable()
            .aspectRatio(trashBinSize.width / trashBinSize.height, contentMode: .fill)
            .frame(maxWidth: .infinity)
            .frame(height: trashBinSize.height)
    }

    private var discardDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                viewModel.updateDrag(translationHeight: value.translation.height)
            }
            .onEnded { value in
                if CardResultViewModel.shouldDiscard(dragOffset: max(0, value.translation.height)) {
                    onComplete()
                } else {
                    withAnimation(.spring()) {
                        viewModel.resetDrag()
                    }
                }
            }
    }
}

private struct DashedDivider: View {
    var body: some View {
        DashedLine()
            .stroke(Color.colorGray950, style: StrokeStyle(lineWidth: 1.3, dash: [4]))
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
        viewModel: CardResultViewModel(),
        onComplete: {}
    )
}
