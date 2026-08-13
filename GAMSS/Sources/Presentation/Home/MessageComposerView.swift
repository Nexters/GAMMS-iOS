//
//  MessageComposerView.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import SwiftUI

/// 메시지 입력창의 실측 콘텐츠 높이를 상위로 전달하기 위한 PreferenceKey.
/// `heightMeasuringText`(투명, 실제 렌더링 안 됨)의 크기를 GeometryReader로 재서 흘려보낸다.
private struct ComposerContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = MessageComposerLayout.collapsedHeight
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// 홈 화면 메시지 입력창. 입력이 비어있으면 한 줄(collapsed)로, 입력이 생기면 콘텐츠 높이만큼
/// 자라나는(expanded) 박스로 표시된다. 감정 다중 선택 드롭다운과 전송 버튼을 함께 갖는다.
///
/// TextEditor는 collapsed/expanded 어느 상태에서든 항상 같은 인스턴스로 유지한다 — 상태 전환마다
/// TextEditor를 새로 만들면 그 순간 키보드 포커스가 끊길 수 있다. 대신 감정 트리거/전송 버튼을
/// `.overlay(alignment: .bottom...)`로 박스 하단에 얹어, collapsed(박스 높이가 한 줄 높이와 같음)일
/// 때는 자연스럽게 텍스트와 한 줄에 겹쳐 보이고 expanded일 때는 텍스트 아래 별도 줄로 보이게 한다.
struct MessageComposerView: View {
    @Binding var input: String
    let selectedEmotions: Set<EmotionCharacter>
    @Binding var isEmotionPickerOpen: Bool
    let isSendDisabled: Bool
    let onToggleEmotion: (EmotionCharacter) -> Void
    let onCommit: () -> Void
    /// `HomeViewModel.updateInput(_:)`와 동일한 계약: 정규화된 값을 돌려주는 대신 이미 바인딩된
    /// input을 직접 갱신하고, 키보드를 내려야 하면 true를 돌려준다.
    let onInputChange: (String) -> Bool
    /// 포커스 상태는 상위(HomeView)가 소유한다 — 빈 화면 탭으로 키보드를 내리는 처리가 상위에
    /// 있어, 이 뷰가 자체 `@FocusState`를 따로 가지면 상위에서 그 상태를 제어할 수 없다.
    var isFocused: FocusState<Bool>.Binding

    @State private var measuredContentHeight: CGFloat = MessageComposerLayout.collapsedHeight

    private let controlsRowHeight: CGFloat = 40

    private var isExpanded: Bool { !input.isEmpty }

    private var boxHeight: CGFloat {
        isExpanded
            ? MessageComposerLayout.clampedHeight(forMeasuredContentHeight: measuredContentHeight)
            : MessageComposerLayout.collapsedHeight
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing200) {
            composerBox
            if isEmotionPickerOpen {
                emotionGrid
            }
        }
    }

    private var composerBox: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: Radius.radius300)
                .fill(Color.colorGray025)

            heightMeasuringText

            if input.isEmpty {
                Text("무슨 이야기를 버려볼까요?")
                    .typography(.body3Regular)
                    .foregroundStyle(Color.colorGray400)
                    .padding(.horizontal, Spacing.spacing300)
                    .frame(maxWidth: .infinity, minHeight: MessageComposerLayout.collapsedHeight, alignment: .leading)
            }

            TextEditor(text: $input)
                .typography(.body3Regular)
                .foregroundStyle(Color.colorGray950)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, Spacing.spacing200)
                .padding(.bottom, isExpanded ? controlsRowHeight : 0)
                .focused(isFocused)
                .onChange(of: input) { _, newValue in
                    if onInputChange(newValue) { isFocused.wrappedValue = false }
                }
        }
        .frame(height: boxHeight)
        .animation(.easeInOut(duration: 0.2), value: boxHeight)
        .onPreferenceChange(ComposerContentHeightPreferenceKey.self) { measuredContentHeight = $0 }
        .overlay(alignment: .bottomLeading) {
            emotionTrigger
                .padding(.horizontal, Spacing.spacing300)
                .padding(.bottom, Spacing.spacing150)
        }
        .overlay(alignment: .bottomTrailing) {
            submitButton
                .padding(.horizontal, Spacing.spacing200)
                .padding(.bottom, Spacing.spacing100)
        }
    }

    /// 실제로는 그려지지 않는(opacity 0) 측정용 텍스트. TextEditor와 동일한 폰트/패딩으로
    /// 배치해 GeometryReader로 콘텐츠 높이를 재고, 그 값을 `measuredContentHeight`로 흘려보낸다.
    private var heightMeasuringText: some View {
        Text(input.isEmpty ? " " : input)
            .typography(.body3Regular)
            .padding(.horizontal, Spacing.spacing200)
            .padding(.bottom, isExpanded ? controlsRowHeight : 0)
            .fixedSize(horizontal: false, vertical: true)
            .opacity(0)
            .allowsHitTesting(false)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(key: ComposerContentHeightPreferenceKey.self, value: proxy.size.height)
                }
            )
    }

    private var emotionTrigger: some View {
        Button {
            isEmotionPickerOpen.toggle()
        } label: {
            HStack(spacing: Spacing.spacing025) {
                Text("감정")
                    .typography(.body4Regular)
                Image(systemName: isEmotionPickerOpen ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10))
            }
            .foregroundStyle(Color.colorGray500)
        }
    }

    private var submitButton: some View {
        Button(action: onCommit) {
            // TODO: 디자인팀에서 활성/비활성 sendButton 에셋 전달 예정 — 도착하면 SF Symbol 대신 교체.
            Image(systemName: "arrow.up")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isSendDisabled ? Color.colorGray400 : Color.colorWhite)
                .frame(width: 32, height: 32)
                .background(isSendDisabled ? Color.colorGray200 : Color.colorGray950)
                .clipShape(Circle())
        }
        .disabled(isSendDisabled)
    }

    private var emotionGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: Spacing.spacing200) {
            ForEach(EmotionCharacter.pickerOrder, id: \.self) { emotion in
                emotionOption(emotion)
            }
        }
        .padding(Spacing.spacing300)
        .background(Color.colorWhite)
        .clipShape(RoundedRectangle(cornerRadius: Radius.radius200))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.radius200)
                .stroke(Color.colorGray200)
        )
    }

    private func emotionOption(_ emotion: EmotionCharacter) -> some View {
        let isSelected = selectedEmotions.contains(emotion)
        // 마지막 1개 남은 선택은 해제할 수 없다 — 흐리게 표시해 "더 해제 안 됨"을 알린다.
        let isLocked = isSelected && selectedEmotions.count == 1

        return Button {
            onToggleEmotion(emotion)
        } label: {
            HStack(spacing: Spacing.spacing050) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .foregroundStyle(isSelected ? Color.colorGray950 : Color.colorGray300)
                Text(emotion.pickerLabel)
                    .typography(.body4Regular)
                    .foregroundStyle(Color.colorGray800)
            }
            .opacity(isLocked ? 0.4 : 1)
        }
    }
}

/// `@FocusState`는 View에만 선언할 수 있어, Preview용으로 이를 소유하는 작은 래퍼 뷰를 둔다.
private struct MessageComposerPreviewContainer: View {
    @State var input: String
    @State var selectedEmotions: Set<EmotionCharacter>
    @State var isEmotionPickerOpen: Bool
    @FocusState private var isFocused: Bool

    var body: some View {
        MessageComposerView(
            input: $input,
            selectedEmotions: selectedEmotions,
            isEmotionPickerOpen: $isEmotionPickerOpen,
            isSendDisabled: input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            onToggleEmotion: { emotion in
                if selectedEmotions.contains(emotion) {
                    if selectedEmotions.count > 1 { selectedEmotions.remove(emotion) }
                } else {
                    selectedEmotions.insert(emotion)
                }
            },
            onCommit: {},
            onInputChange: { newValue in
                input = newValue
                return false
            },
            isFocused: $isFocused
        )
        .padding(Spacing.spacing400)
    }
}

#Preview("collapsed") {
    MessageComposerPreviewContainer(
        input: "",
        selectedEmotions: Set(EmotionCharacter.allCases),
        isEmotionPickerOpen: false
    )
}

#Preview("expanded with emotion picker open") {
    MessageComposerPreviewContainer(
        input: "이게 뭐냐아~",
        selectedEmotions: [.joy, .sadness],
        isEmotionPickerOpen: true
    )
}
