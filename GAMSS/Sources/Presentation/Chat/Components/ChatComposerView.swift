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
        HStack(alignment: .bottom, spacing: Spacing.spacing100) {
            // 답장 미리보기와 텍스트 입력이 한 박스(배경+테두리) 안에 같이 들어가야 하므로,
            // 둘을 이 VStack으로 묶은 뒤 박스 스타일을 여기 하나에만 적용한다.
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
                .onChange(of: text) { _, newValue in
                    if onTextChange(newValue) {
                        isFocused = false
                    }
                }
            }
            .padding(.vertical, Spacing.spacing150)
            .padding(.horizontal, Spacing.spacing200)
            .background(Color.colorGray025)
            .overlay(
                Rectangle()
                    .strokeBorder(Color.colorGray950, lineWidth: 1)
            )

            if Self.hasText(text) {
                sendButton
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

    private var sendButton: some View {
        Button(action: onSend) {
            Image(systemName: "arrow.up")
                .foregroundStyle(Color.colorGray025)
                .frame(width: 24, height: 24)
                .padding(Spacing.spacing100)
                .background(
                    RoundedRectangle(cornerRadius: Radius.radius200)
                        .fill(Color.colorGray900)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.radius200)
                        .strokeBorder(Color.colorGray950, lineWidth: 1)
                )
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
