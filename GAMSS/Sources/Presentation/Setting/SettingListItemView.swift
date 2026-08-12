//
//  SettingListItemView.swift
//  GAMSS
//
//  Created by LEEGEONJUN on 8/12/26.
//

import SwiftUI

struct SettingListItemView: View {
    let item: SettingItem
    
    @State private var presentedWebPage: WebPage?
    
    var body: some View {
        Group {
            switch item.action {
            case .navigate:
                NavigationLink {
                    Text("\(item.title) 화면 이동")
                } label: { row }
                .buttonStyle(.plain)
                
            case let .web(urlString):
                Button {
                    presentWeb(urlString)
                } label: { row }
                .buttonStyle(.plain)
                
            case .none:
                row
            }
        }
        .sheet(item: $presentedWebPage) { page in
            SafariView(url: page.url)
                .ignoresSafeArea()
        }
    }
}

// MARK: - ItemView

extension SettingListItemView {
    private var row: some View {
        HStack(spacing: Spacing.spacing100) {
            Text(item.title)
                .typography(.body3Medium)
                .foregroundStyle(Color.colorGray950)
            
            if item == .notification {
                badge(isOn: false)
            }
            
            Spacer(minLength: 0)
            
            if item == .appVersion {
                Text(Environment.appVersion)
                    .typography(.body3Medium)
                    .foregroundStyle(Color.colorGray500)
            }
        }
        .padding(.vertical, Spacing.spacing400)
        .contentShape(Rectangle())
    }
    
    private func badge(isOn: Bool) -> some View {
        Text(isOn ? "ON" : "OFF")
            .typography(.body6Medium)
            .foregroundStyle(Color.colorGray900)
            .padding(.horizontal, Spacing.spacing075)
            .padding(.vertical, Spacing.spacing025)
            .background(Color.colorGray200)
            .clipShape(Capsule())
    }
    
    private func presentWeb(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        presentedWebPage = WebPage(url: url)
    }
}

private struct WebPage: Identifiable {
    let id = UUID()
    let url: URL
}

#Preview {
    NavigationStack {
        VStack(spacing: 0) {
            SettingListItemView(item: .accountInfo)
            SettingListItemView(item: .notification)
            SettingListItemView(item: .termsOfService)
            SettingListItemView(item: .appVersion)
        }
        .padding(.horizontal, Spacing.spacing300)
    }
}
