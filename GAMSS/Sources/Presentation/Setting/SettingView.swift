//
//  SettingView.swift
//  GAMSS
//
//  Created by LEEGEONJUN on 8/12/26.
//

import SwiftUI

struct SettingView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    @State private var presentedWebPage: WebPage?
    
    var body: some View {
        VStack {
            header
                .padding(.horizontal, 18)
                .padding(.vertical, Spacing.spacing400)
            
            ForEach(SettingSection.allCases) { section in
                ForEach(section.items) { item in
                    settingItem(item)
                        .padding(.horizontal, 18)
                    
                    if item.showsDividerBelow {
                        fullWidthDivider
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.colorWhite)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $presentedWebPage) { page in
            SafariView(url: page.url)
                .ignoresSafeArea()
        }
    }
    
    private var header: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.colorGray900)
            }
            Text("설정")
                .typography(.subtitle2)
                .foregroundStyle(Color.colorGray900)
            Spacer()
        }
    }
    
    private var fullWidthDivider: some View {
        Color.colorGray075
            .frame(height: 2)
            .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func settingItem(_ item: SettingItem) -> some View {
        let row = MenuListItemView(
            title: item.title,
            badgeText: item == .notification ? "OFF" : nil,
            trailingText: item == .appVersion ? Environment.appVersion : nil
        )
        
        switch item.action {
        case .navigate:
            NavigationLink {
                destination(for: item)
            } label: {
                row
            }
            .buttonStyle(.plain)
            
        case let .web(urlString):
            Button {
                presentWeb(urlString)
            } label: {
                row
            }
            .buttonStyle(.plain)
            
        case .none:
            row
        }
    }
    
    @ViewBuilder
    private func destination(for item: SettingItem) -> some View {
        switch item {
        case .accountInfo:
            AccountView(
                title: item.title,
                viewModel: AccountViewModel(
                    logoutUseCase: DefaultLogoutUseCase(
                        authRepository: DefaultAuthRepository(
                            networkManager: NetworkManager.shared,
                            tokenStorage: TokenStorage.shared
                        )
                    ),
                    deleteMemberUseCase: DefaultDeleteMemberUseCase(
                        memberRepository: DefaultMemberRepository(
                            networkManager: NetworkManager.shared,
                            tokenStorage: .shared
                        )
                    )
                )
            )
        case .notification:
            Text("알림 설정 화면 이동")
        case .privacyPolicy, .appVersion:
            EmptyView()
        }
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
        SettingView()
    }
}
