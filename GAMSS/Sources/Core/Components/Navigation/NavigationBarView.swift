//
//  NavigationBarView.swift
//  GAMSS
//
//  Created by 이건준 on 8/31/26.
//

import SwiftUI

enum NavigationBarMetrics {
    static let height: CGFloat = 64
    static let horizontalPadding: CGFloat = Spacing.spacing350
}

/// 시스템 NavigationBar 대신 쓰는 공용 상단 바.
struct NavigationBarView<Trailing: View>: View {
    enum TitlePlacement {
        case leading
        case center
    }

    enum LeadingContent {
        case backButton
        case logo
        case none
    }

    private let title: String?
    private let titlePlacement: TitlePlacement
    private let titleStyle: Typography
    private let titleColor: Color
    private let leadingContent: LeadingContent
    private let onBack: () -> Void
    private let horizontalPadding: CGFloat
    private let trailing: Trailing

    init(
        title: String? = nil,
        titlePlacement: TitlePlacement = .leading,
        titleStyle: Typography = .subtitle2,
        titleColor: Color = .colorGray900,
        leading: LeadingContent = .backButton,
        onBack: @escaping () -> Void = {},
        horizontalPadding: CGFloat = NavigationBarMetrics.horizontalPadding,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.titlePlacement = titlePlacement
        self.titleStyle = titleStyle
        self.titleColor = titleColor
        self.leadingContent = leading
        self.onBack = onBack
        self.horizontalPadding = horizontalPadding
        self.trailing = trailing()
    }

    init(
        title: String? = nil,
        titlePlacement: TitlePlacement = .leading,
        titleStyle: Typography = .subtitle2,
        titleColor: Color = .colorGray900,
        showsBackButton: Bool,
        onBack: @escaping () -> Void = {},
        horizontalPadding: CGFloat = NavigationBarMetrics.horizontalPadding,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(
            title: title,
            titlePlacement: titlePlacement,
            titleStyle: titleStyle,
            titleColor: titleColor,
            leading: showsBackButton ? .backButton : .none,
            onBack: onBack,
            horizontalPadding: horizontalPadding,
            trailing: trailing
        )
    }

    var body: some View {
        Group {
            switch titlePlacement {
            case .leading:
                leadingLayout
            case .center:
                centerLayout
            }
        }
        .frame(height: NavigationBarMetrics.height)
        .padding(.horizontal, horizontalPadding)
    }

    private var leadingLayout: some View {
        HStack(spacing: Spacing.spacing200) {
            leadingView

            if let title {
                Text(title)
                    .typography(titleStyle)
                    .foregroundStyle(titleColor)
            }

            Spacer(minLength: 0)

            trailing
        }
    }

    private var centerLayout: some View {
        ZStack {
            if let title {
                Text(title)
                    .typography(titleStyle)
                    .foregroundStyle(titleColor)
            }

            HStack(spacing: Spacing.spacing200) {
                leadingView

                Spacer(minLength: 0)

                trailing
            }
        }
    }

    @ViewBuilder
    private var leadingView: some View {
        switch leadingContent {
        case .backButton:
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.colorGray900)
            }
            .accessibilityLabel("뒤로가기")

        case .logo:
            Image("logoGamss")
                .resizable()
                .scaledToFit()
                .frame(height: 24)

        case .none:
            EmptyView()
        }
    }
}

#Preview("Push") {
    VStack {
        NavigationBarView(title: "설정", onBack: {})
        NavigationBarView(title: "보관함", onBack: {}) {
            Text("비우기")
                .typography(.body5Medium)
                .foregroundStyle(Color.colorGray900)
        }
    }
}

#Preview("Tab logo") {
    NavigationBarView(leading: .logo) {
        Image("gear")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
    }
}

#Preview("Center") {
    NavigationBarView(
        title: "2026.08.31",
        titlePlacement: .center,
        titleStyle: .subtitle3,
        titleColor: .colorGray950,
        onBack: {}
    ) {
        HStack(spacing: Spacing.spacing400) {
            Image("iconCardGenerate")
            Image("iconTokenUsage")
        }
    }
}
