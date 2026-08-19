//
//  TokenUsagePopoverView.swift
//  GAMSS
//
//  Created by cchanmi on 8/18/26.
//

import SwiftUI

struct TokenUsagePopoverView: View {
    let tokenUsage: TokenUsage?
    let isLoading: Bool
    let errorMessage: String?
    let onRetry: () -> Void

    var body: some View {
        Group {
            if isLoading {
                loadingContent
            } else if let errorMessage {
                errorContent(errorMessage)
            } else if let tokenUsage {
                usageContent(tokenUsage)
            } else {
                loadingContent
            }
        }
        .padding(Spacing.spacing300)
        .frame(width: 220)
        .background(Color.colorWhite)
        .overlay(
            Rectangle()
                .strokeBorder(Color.colorGray950, lineWidth: 1)
        )
    }

    private var loadingContent: some View {
        HStack {
            Text("토큰 사용량")
                .typography(.subtitle4)
                .foregroundStyle(Color.colorGray900)

            Spacer()

            ProgressView()
        }
    }

    private func errorContent(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.spacing200) {
            Text(message)
                .typography(.body5Medium)
                .foregroundStyle(Color.colorGray900)

            Button("다시 시도", action: onRetry)
                .typography(.body5Medium)
                .foregroundStyle(Color.colorGray900)
                .buttonStyle(.plain)
        }
    }

    private func usageContent(_ usage: TokenUsage) -> some View {
        VStack(alignment: .leading, spacing: Spacing.spacing200) {
            HStack {
                Text("토큰 사용량")
                    .typography(.subtitle4)
                    .foregroundStyle(Color.colorGray900)

                Spacer()

                Text("\(usage.percent)% 사용됨")
                    .typography(.body5Medium)
                    .foregroundStyle(Color.colorGray900)
            }

            progressBar(percent: usage.percent)

            Text("오전 5:00에 초기화됩니다")
                .typography(.caption3)
                .foregroundStyle(Color.colorGray600)
        }
    }

    private func progressBar(percent: Int) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.colorGray075)
                    .overlay(
                        Rectangle()
                            .strokeBorder(Color.colorGray900, lineWidth: 1)
                    )

                Rectangle()
                    .fill(Color.colorGray800)
                    .overlay(
                        Rectangle()
                            .strokeBorder(Color.colorGray900, lineWidth: 1)
                    )
                    .frame(width: geometry.size.width * CGFloat(percent) / 100)
            }
        }
        .frame(height: 8)
    }
}

#Preview("정상") {
    TokenUsagePopoverView(
        tokenUsage: TokenUsage(usedTokens: 60000, dailyLimit: 100000, exceeded: false),
        isLoading: false,
        errorMessage: nil,
        onRetry: {}
    )
}

#Preview("로딩 중") {
    TokenUsagePopoverView(
        tokenUsage: nil,
        isLoading: true,
        errorMessage: nil,
        onRetry: {}
    )
}

#Preview("에러") {
    TokenUsagePopoverView(
        tokenUsage: nil,
        isLoading: false,
        errorMessage: "토큰 사용량을 불러오지 못했어요",
        onRetry: {}
    )
}
