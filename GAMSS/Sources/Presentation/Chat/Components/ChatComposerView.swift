//
//  ChatComposerView.swift
//  GAMSS
//
//  Created by cchanmi on 8/12/26.
//

import SwiftUI

/// 채팅 입력창. 텍스트가 늘어나면서 최대 5줄까지 커지고 그 이후 내부 스크롤되는 동작은
/// TextField(axis: .vertical) + lineLimit(1...5)가 iOS 16+에서 기본 제공하므로 새로 구현하지
/// 않는다 — 이 뷰는 배경/테두리/텍스트 스타일과 전송 버튼 노출 조건만 담당한다.
struct ChatComposerView: View {
    @Binding var text: String
    let isSendDisabled: Bool
    let replyTargetLabel: String?
    let replyTargetContent: String?
    let onCancelReply: () -> Void
    let onSend: () -> Void
    let onTextChange: (String) -> Bool
    @FocusState.Binding var isFocused: Bool

    var body: some View {
        // 답장 미리보기와 텍스트 입력이 한 박스(배경+테두리) 안에 같이 들어가야 하므로, 이 VStack
        // 하나에 박스 스타일을 적용한다. 전송 버튼은 옆에 따로 두지 않고(그러면 박스 폭이
        // 줄어든다) 박스 위에 overlay로 얹어 홈 화면 입력창과 같은 방식으로 안쪽에 떠 있게 한다.
        VStack(alignment: .leading, spacing: Spacing.spacing100) {
            if let replyTargetLabel, let replyTargetContent {
                replyPreview(label: replyTargetLabel, content: replyTargetContent)
            }

            TextField(
                "메시지 입력",
                text: $text,
                // TextField(prompt:)는 Text 타입을 요구해서 `.typography(_:)`(some View 반환)를
                // 쓸 수 없다 — Text 자체의 font/tracking으로 직접 맞춘다. lineSpacing은 Text에
                // 없는 API라 여기선 적용 대상이 아니다.
                prompt: Text("메시지 입력")
                    .font(.custom(Typography.body4Medium.metrics.weight.postScriptName(), size: Typography.body4Medium.metrics.fontSize))
                    .tracking(Typography.body4Medium.metrics.letterSpacing)
                    .foregroundColor(Color.colorGray400),
                axis: .vertical
            )
            .typography(.body4Medium)
            .foregroundStyle(Color.colorGray950)
            .tint(Color.colorGray950)
            .focused($isFocused)
            .lineLimit(1...5)
            // 전송 버튼이 뜨면 마지막 줄 텍스트가 버튼 밑에 깔리지 않도록 오른쪽 여백을 예약한다.
            .padding(.trailing, Self.hasText(text) ? 40 : 0)
            .onChange(of: text) { _, newValue in
                if onTextChange(newValue) {
                    isFocused = false
                }
            }
        }
        .padding(.vertical, Spacing.spacing150)
        .padding(.horizontal, Spacing.spacing200)
        // 답장 미리보기 없이 한 줄만 입력 중일 때도 최소 48pt는 확보해야, 32pt 버튼 +
        // 위아래 8pt 여백(=48)이 박스 밖으로 삐져나오지 않는다. 여러 줄로 늘어나거나 답장
        // 미리보기가 붙으면 이 최소값 위로 자연스럽게 커진다.
        .frame(minHeight: Spacing.spacing800)
        .background(Color.colorGray025)
        .overlay(
            Rectangle()
                .strokeBorder(Color.colorGray950, lineWidth: 1)
        )
        .overlay(alignment: .bottomTrailing) {
            if Self.hasText(text) {
                sendButton
                    .padding(Spacing.spacing100)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, Spacing.spacing200)
        .background(Color.colorWhite)
    }

    static func hasText(_ text: String) -> Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func replyPreview(label: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.spacing050) {
            HStack(spacing: Spacing.spacing100) {
                Text(label)
                    .typography(.body5Medium)
                    .foregroundStyle(Color.colorGray950)

                Spacer(minLength: 0)

                Button(action: onCancelReply) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.colorGray400)
                }
                .accessibilityLabel("답장 취소")
            }

            Text(content)
                .typography(.body4Medium)
                .foregroundStyle(Color.colorGray500)
                .lineLimit(1)
        }
    }

    // 비활성화 상태는 화면에 노출되지 않는다(hasText(text)가 false면 버튼 자체가 안 뜬다) —
    // 그래서 홈 화면과 달리 sendButtonDisabled 에셋은 쓰지 않는다.
    private var sendButton: some View {
        Button(action: onSend) {
            Image("sendButtonEnabled")
                .resizable()
                .frame(width: 32, height: 32)
        }
        .disabled(isSendDisabled)
        .accessibilityLabel("전송")
    }
}

#Preview("일반") {
    @Previewable @State var text = ""
    @Previewable @FocusState var isFocused: Bool

    return ChatComposerView(
        text: $text,
        isSendDisabled: text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
        replyTargetLabel: nil,
        replyTargetContent: nil,
        onCancelReply: {},
        onSend: {},
        onTextChange: { _ in false },
        isFocused: $isFocused
    )
}

#Preview("답장 모드") {
    @Previewable @State var text = "안녕"
    @Previewable @FocusState var isFocused: Bool

    return ChatComposerView(
        text: $text,
        isSendDisabled: text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
        replyTargetLabel: "불안에게 답장",
        replyTargetContent: "안녕하세용",
        onCancelReply: {},
        onSend: {},
        onTextChange: { _ in false },
        isFocused: $isFocused
    )
}
