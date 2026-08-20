//
//  ModalContentView.swift
//  GAMSS
//
//  Created by 이건준 on 8/14/26.
//

import SwiftUI

struct ModalContentView<ExtraContent: View>: View {
    let title: String
    let subtitle: String?
    let actions: [ModalAction]
    let extraContent: ExtraContent

    init(
        title: String,
        subtitle: String? = nil,
        actions: [ModalAction],
        @ViewBuilder extraContent: () -> ExtraContent = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actions = actions
        self.extraContent = extraContent()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection

            extraContent

            Spacer()
                .frame(height: 20)

            actionSection
        }
        .padding(.all, 20)
        .background(Color.colorWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private extension ModalContentView {
    @ViewBuilder
    var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .typography(.subtitle2)
                .foregroundStyle(Color.colorGray950)

            if let subtitle {
                Text(subtitle)
                    .typography(.body4Medium)
                    .foregroundStyle(Color.colorGray500)
            }
        }
    }
}


private extension ModalContentView {
    @ViewBuilder
    var actionSection: some View {
        switch actions.count {
        case 1:
            actionButton(actions[0])

        case 2:
            HStack(spacing: 8) {
                actionButton(actions[0])
                actionButton(actions[1])
            }

        default:
            EmptyView()
        }
    }

    func actionButton(_ action: ModalAction) -> some View {
        Button(action: action.action) {
            Text(action.title)
                .typography(.title5)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
        }
        .foregroundStyle(action.style.foregroundColor)
        .background(action.style.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
