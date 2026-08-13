//
//  HomeView.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @FocusState private var isInputFocused: Bool
    @State private var isSettingPresented = false

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // 종이 질감 배경 — 에셋은 추후 전달 예정. 도착 전까지는 Image(_:)가 빈 화면으로
                // 렌더링될 뿐 빌드/런타임 에러는 나지 않는다.
                Image("homeBackgroundPaper")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                decorations

                // 화면의 빈 영역(다른 인터랙티브 뷰가 가리지 않는 부분)을 탭하면 키보드와 감정
                // 드롭다운을 내린다. TextEditor/버튼은 그 위에 그려져 자기 탭을 먼저 가져가므로
                // 커서 이동 등은 방해받지 않는다.
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isInputFocused = false
                        viewModel.isEmotionPickerOpen = false
                    }

                VStack(alignment: .leading, spacing: Spacing.spacing500) {
                    header

                    greeting

                    MessageComposerView(
                        input: $viewModel.input,
                        selectedEmotions: viewModel.selectedEmotions,
                        isEmotionPickerOpen: $viewModel.isEmotionPickerOpen,
                        isSendDisabled: viewModel.isSendDisabled,
                        onToggleEmotion: { viewModel.toggleEmotion($0) },
                        onCommit: { Task { await viewModel.send() } },
                        onInputChange: { viewModel.updateInput($0) },
                        isFocused: $isInputFocused
                    )

                    Spacer()
                }
                .padding(Spacing.spacing400)
            }
            .navigationBarHidden(true)
            .navigationDestination(item: $viewModel.createdConversationId) { conversationId in
                ChatView(
                    viewModel: ChatViewModel(
                        sendMessageUseCase: SendMessageUseCase(conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)),
                        getMessagesUseCase: GetMessagesUseCase(conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)),
                        summaryStore: LazyConversationSummaryStore(),
                        conversationId: conversationId,
                        initialSentMessage: viewModel.createdSentMessage
                    )
                )
                .toolbar(.hidden, for: .tabBar)
            }
            .navigationDestination(isPresented: $isSettingPresented) {
                SettingView()
            }
        }
        .alert(viewModel.alertMessage ?? "", isPresented: Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.alertMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        }
    }

    private var header: some View {
        HStack {
            Image("logoGamss")
                .resizable()
                .scaledToFit()
                .frame(height: 24)

            Spacer()

            Button {
                isSettingPresented = true
            } label: {
                // TODO: 디자인팀에서 햄버거 메뉴 에셋 전달 예정 — 도착하면 SF Symbol 대신 교체.
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(Color.colorGray500)
            }
        }
    }

    /// "{닉네임}님 오늘도" / "감쓰에 버려볼까요?" — 닉네임 부분만 분홍 배경으로 하이라이트한다.
    /// 닉네임 서버 연동은 이후 단계에서 붙인다 — 지금은 UserManager에 값이 없으면 fallback을 쓴다.
    private var greeting: some View {
        let nickname = UserManager.shared.user?.nickname ?? "OO"
        return VStack(alignment: .leading, spacing: Spacing.spacing050) {
            HStack(spacing: 0) {
                Text(nickname)
                    .typography(.title3)
                    .foregroundStyle(Color.colorGray950)
                    .padding(.horizontal, Spacing.spacing050)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.radius050)
                            .fill(Color.colorPink.opacity(0.5))
                    )
                Text("님 오늘도")
                    .typography(.title3)
                    .foregroundStyle(Color.colorGray950)
            }
            Text("감쓰에 버려볼까요?")
                .typography(.title3)
                .foregroundStyle(Color.colorGray950)
        }
    }

    /// 포스트잇/테이프 장식 3종. 순수 장식이라 터치를 가로채지 않는다(`allowsHitTesting(false)`).
    /// 위치/회전값은 Figma 레드라인 확정 전 임시값 — 실제 에셋 도착 후 다듬는다.
    private var decorations: some View {
        GeometryReader { geo in
            ZStack {
                // TODO: 디자인팀 에셋 전달 예정 — /Users/hwangchanmi/Desktop/감쓰/홈화면/ 참고.
                Image("homeStickyNote")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88)
                    .rotationEffect(.degrees(10))
                    .position(x: geo.size.width * 0.82, y: geo.size.height * 0.27)

                Image("homeTapePink")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130)
                    .rotationEffect(.degrees(-8))
                    .position(x: geo.size.width * 0.78, y: geo.size.height * 0.68)

                Image("homeTapeOutline")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90)
                    .rotationEffect(.degrees(-12))
                    .position(x: geo.size.width * 0.28, y: geo.size.height * 0.76)
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel(
            sendMessageUseCase: SendMessageUseCase(
                conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)
            )
        )
    )
}
