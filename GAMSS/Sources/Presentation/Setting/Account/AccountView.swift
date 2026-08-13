//
//  AccountView.swift
//  GAMSS
//
//  Created by LEEGEONJUN on 8/13/26.
//

import SwiftUI

struct AccountView: View {
    let title: String
    
    @StateObject private var viewModel: AccountViewModel
    @SwiftUI.Environment(LoginSession.self) private var loginSession
    @SwiftUI.Environment(UserManager.self) private var userManager
    @SwiftUI.Environment(\.dismiss) private var dismiss
    
    init(title: String, viewModel: AccountViewModel) {
        self.title = title
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 18)
                .padding(.vertical, Spacing.spacing400)
            
            ForEach(AccountItem.allCases) { item in
                accountItem(item)
                    .padding(.horizontal, 18)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.colorWhite)
        .toolbar(.hidden, for: .navigationBar)
        .alert(
            viewModel.errorMessage ?? "",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("확인", role: .cancel) {}
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
            Text(title)
                .typography(.subtitle2)
                .foregroundStyle(Color.colorGray900)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func accountItem(_ item: AccountItem) -> some View {
        let row = MenuListItemView(
            title: item.title,
            titleColor: item.titleColor,
            trailingText: trailingText(for: item)
        )
        
        switch item.action {
        case .navigate:
            NavigationLink {
                Text("\(item.title) 화면 이동")
            } label: {
                row
            }
            .buttonStyle(.plain)
            
        case .logout:
            Button {
                Task {
                    await viewModel.logout()
                    loginSession.value = .current
                }
            } label: {
                row
            }
            .buttonStyle(.plain)
            
        case .none:
            row
        case .withdraw:
            Button {
                Task {
                    await viewModel.deleteMember()
                    loginSession.value = .current
                }
            } label: {
                row
            }
            .buttonStyle(.plain)
        }
    }
    
    private func trailingText(for item: AccountItem) -> String? {
        switch item {
        case .changeNickname:
            userManager.user?.nickname ?? "-"
        case .email:
            userManager.user?.email ?? "-"
        case .logout, .withdraw:
            nil
        }
    }
}

#Preview {
    NavigationStack {
        AccountView(
            title: SettingItem.accountInfo.title,
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
        .environment(LoginSession())
        .environment(UserManager.shared)
    }
}
