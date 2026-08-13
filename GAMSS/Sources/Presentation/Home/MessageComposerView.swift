//
//  MessageComposerView.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import SwiftUI

/// 홈 화면 메시지 입력창. 입력이 비어있으면 collapsed(64), 입력이 생기면 expanded(149) 고정
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
    /// collapsed일 때 TextEditor 자체에 주는 높이. 한 줄 타이포그래피 높이보다 살짝 여유를
    /// 둬서 커서/디센더가 안 잘리게 한다.
    private let collapsedLineHeight: CGFloat = Typography.body3Regular.metrics.lineHeight + Spacing.spacing200

    private var isExpanded: Bool { !input.isEmpty }

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

            if input.isEmpty {
                Text("무슨 이야기를 버려볼까요?")
                    .typography(.body3Regular)
                    .foregroundStyle(Color.colorGray400)
                    .lineLimit(1)
                    .padding(.leading, Spacing.spacing300)
                    .padding(.trailing, 110) // 오른쪽 감정 트리거+전송 버튼과 겹치지 않게 예약
                    .frame(maxWidth: .infinity, minHeight: MessageComposerLayout.collapsedHeight, alignment: .leading)
            }

            // collapsed일 때는 TextEditor 자체 높이를 한 줄 정도(collapsedLineHeight)로 줄이고
            // 그 바깥을 꽉 채우는 프레임으로 세로 중앙 정렬한다 — placeholder(위에서 세로
            // 중앙 정렬)와 실제 커서 위치가 어긋나지 않게. expanded일 때는 자연스럽게 위에서
            // 아래로 채운다. if/else로 TextEditor 자체를 분기하면 포커스가 끊길 수 있어
            // 인스턴스는 하나로 유지하고 modifier만 상태에 따라 바꾼다.
            TextEditor(text: $input)
                .typography(.body3Regular)
                .foregroundStyle(Color.colorGray950)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, Spacing.spacing200)
                .padding(.bottom, isExpanded ? controlsRowHeight : 0)
                .frame(height: isExpanded ? nil : collapsedLineHeight)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: isExpanded ? .top : .center)
                .focused(isFocused)
                .onChange(of: input) { _, newValue in
                    if onInputChange(newValue) { isFocused.wrappedValue = false }
                }
        }
        .frame(height: MessageComposerLayout.height(isExpanded: isExpanded))
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
        .overlay(alignment: isExpanded ? .bottom : .center) {
            controlsRow
        }
    }

    /// 감정 선택 기능은 보류 상태 — 트리거 버튼과 드롭다운을 숨긴다. 아래 `emotionTrigger`/
    /// `emotionGrid`/`isEmotionPickerOpen` 관련 코드는 지우지 않고 남겨뒀다: 다시 켤 때
    /// `isEmotionSelectionEnabled`만 true로 되돌리면 된다.
    private let isEmotionSelectionEnabled = false

    /// collapsed일 때는 placeholder 옆(오른쪽)에 감정 트리거+전송 버튼이 나란히 붙고,
    /// expanded일 때는 박스 하단 한 줄에 감정 트리거(좌)와 전송 버튼(우)이 양 끝으로 벌어진다.
    private var controlsRow: some View {
        Group {
            if isExpanded {
                HStack {
                    if isEmotionSelectionEnabled { emotionTrigger }
                    Spacer()
                    submitButton
                }
                .padding(.horizontal, Spacing.spacing200)
                .padding(.bottom, Spacing.spacing150)
            } else {
                HStack(spacing: Spacing.spacing150) {
                    Spacer()
                    if isEmotionSelectionEnabled { emotionTrigger }
                    submitButton
                }
                .padding(.horizontal, Spacing.spacing300)
            }
        }
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
            if isSendDisabled {
                Image("sendButtonDisabled")
                    .resizable()
                    .frame(width: 32, height: 32)
            } else {
                // TODO: 디자인팀에서 활성 상태 sendButton 에셋 전달 예정 — 도착하면 SF Symbol 대신 교체.
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.colorWhite)
                    .frame(width: 32, height: 32)
                    .background(Color.colorGray950)
                    .clipShape(Circle())
            }
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
