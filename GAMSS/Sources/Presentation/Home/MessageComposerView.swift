//
//  MessageComposerView.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import SwiftUI

/// 홈 화면 메시지 입력창. 포커스가 없으면 collapsed(116), 포커스가 있으면 expanded(150) 고정
/// 높이로 표시된다 — 콘텐츠 길이에 따라 계속 늘어나지 않고, 넘치는 텍스트는 TextEditor 내부
/// 스크롤로 처리된다. 감정 다중 선택 드롭다운과 전송 버튼을 함께 갖는다.
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

    /// 박스 하단 컨트롤 행(감정 트리거/전송 버튼)이 차지하는 높이 — expanded일 때 TextEditor
    /// 텍스트가 그 밑에 깔리지 않도록 그만큼 하단 여백을 예약한다.
    private let controlsRowHeight: CGFloat = 40
    private var isExpanded: Bool { isFocused.wrappedValue }

    var body: some View {
        composerBox
    }

    private var composerBox: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(Color.colorGray025)
                .overlay(
                    Rectangle()
                        .strokeBorder(Color.colorGray950, lineWidth: 1)
                )

            if input.isEmpty {
                Text("무슨 이야기를 버려볼까요?")
                    .typography(.body3Regular)
                    .foregroundStyle(Color.colorGray400)
                    .lineLimit(1)
                    .padding(.leading, Spacing.spacing300)
                    .padding(.top, Spacing.spacing300)
            }

            TextEditor(text: $input)
                .typography(.body3Regular)
                .foregroundStyle(Color.colorGray950)
                .scrollContentBackground(.hidden)
                .padding(.leading, Spacing.spacing200)
                .padding(.trailing, Spacing.spacing200)
                .padding(.top, Spacing.spacing200)
                .padding(.bottom, controlsRowHeight)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .focused(isFocused)
                .onChange(of: isFocused.wrappedValue) { _, isFocusedNow in
                    if isFocusedNow { isEmotionPickerOpen = false }
                }
                .onChange(of: input) { _, newValue in
                    if onInputChange(newValue) { isFocused.wrappedValue = false }
                }
        }
        .frame(height: MessageComposerLayout.height(isExpanded: isExpanded))
        .overlay(alignment: .bottom) {
            controlsRow
        }
        // .overlay() 다음으로 옮겨서 프레임 높이 변화와 overlay padding 변화가 같은
        // 트랜잭션으로 묶이게 한다.
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }

    private let isEmotionSelectionEnabled = true

    private var controlsRow: some View {
        HStack {
            if isEmotionSelectionEnabled { emotionTrigger }
            Spacer()
            submitButton
        }
        .padding(.horizontal, Spacing.spacing300)
        .padding(.bottom, Spacing.spacing300)
    }

    private var emotionTrigger: some View {
        Button {
            isFocused.wrappedValue = false
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
        .overlay(alignment: .topLeading) {
            if isEmotionPickerOpen {
                emotionGrid
                    .padding(.top, controlsRowHeight) // 트리거 버튼 아래(박스 바깥)로 밀어냄
            }
        }
    }

    private var submitButton: some View {
        Button(action: onCommit) {
            Image(isSendDisabled ? "sendButtonDisabled" : "sendButtonEnabled")
                .resizable()
                .frame(width: 32, height: 32)
        }
        .disabled(isSendDisabled)
    }

    private var emotionGrid: some View {
        let topRow = EmotionCharacter.pickerOrder.prefix(3)
        let bottomRow = EmotionCharacter.pickerOrder.suffix(3)
        return VStack(spacing: Spacing.spacing350) {
            HStack(spacing: Spacing.spacing350) {
                ForEach(Array(topRow), id: \.self) { emotion in
                    emotionOption(emotion)
                }
            }
            HStack(spacing: Spacing.spacing350) {
                ForEach(Array(bottomRow), id: \.self) { emotion in
                    emotionOption(emotion)
                }
            }
        }
        .padding(Spacing.spacing400)
        .background(Color.colorWhite)
        .clipShape(RoundedRectangle(cornerRadius: Radius.radius200))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.radius200)
                .stroke(Color.colorGray950, lineWidth: 1.5)
        )
    }

    private func emotionOption(_ emotion: EmotionCharacter) -> some View {
        let isSelected = selectedEmotions.contains(emotion)

        return Button {
            onToggleEmotion(emotion)
        } label: {
            HStack(spacing: Spacing.spacing050) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .foregroundStyle(isSelected ? Color.colorGray950 : Color.colorGray300)
                Text(emotion.pickerLabel)
                    .typography(.body4Regular)
                    .foregroundStyle(Color.colorGray800)
                    .fixedSize(horizontal: true, vertical: false)
            }
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

#Preview("collapsed with emotion picker open") {
    MessageComposerPreviewContainer(
        input: "",
        selectedEmotions: [.joy, .sadness],
        isEmotionPickerOpen: true
    )
}
