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
        // 하나에 박스 스타일(배경/테두리)을 적용한다. 다만 "48pt 확보 + 전송 버튼 얹기"는 박스
        // 전체가 아니라 textFieldRow 하나에만 건다 — 그래야 답장 미리보기가 위에 붙어도 버튼이
        // 그쪽으로 넘어가지 않고 textFieldRow 안에서만 움직인다.
        VStack(alignment: .leading, spacing: Spacing.spacing100) {
            if let replyTargetLabel, let replyTargetContent {
                replyPreview(label: replyTargetLabel, content: replyTargetContent)
                    .padding(.horizontal, Spacing.spacing200)
            }

            textFieldRow
        }
        .background(Color.colorGray025)
        .overlay(
            Rectangle()
                .strokeBorder(Color.colorGray950, lineWidth: 1)
        )
        .padding(.horizontal, 18)
        .padding(.vertical, Spacing.spacing200)
        .background(Color.colorWhite)
    }

    /// 텍스트 입력 한 줄 + 전송 버튼. 이 뷰 자체가 최소 48pt 높이를 스스로 확보하고 그 안에서만
    /// 버튼을 배치하므로, 위에 답장 미리보기가 붙어 있어도 그쪽을 침범하지 않는다 — 미리보기와의
    /// 간격은 바깥 VStack의 spacing(8pt)이 그대로 보장해준다.
    private var textFieldRow: some View {
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
        .padding(.leading, Spacing.spacing200)
        // 전송 버튼이 뜨면 텍스트가 버튼과 16px 이상 떨어지도록 오른쪽 여백을 예약한다.
        .padding(.trailing, Self.hasText(text) ? sendButtonTrailingReservation : Spacing.spacing200)
        .onChange(of: text) { _, newValue in
            if onTextChange(newValue) {
                isFocused = false
            }
        }
        .padding(.vertical, Spacing.spacing150)
        // 한 줄만 입력 중일 때도 최소 48pt는 확보해야, 32pt 버튼 + 위아래 8pt 여백(=48)이
        // 이 행 밖으로 삐져나오지 않는다.
        .frame(minHeight: Spacing.spacing800)
        .overlay(alignment: .bottomTrailing) {
            if Self.hasText(text) {
                sendButton
                    .padding(Spacing.spacing100)
            }
        }
    }

    static func hasText(_ text: String) -> Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 버튼 여백(8) + 버튼 폭(32) + 텍스트와의 간격(16).
    private var sendButtonTrailingReservation: CGFloat {
        Spacing.spacing100 + 32 + Spacing.spacing300
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
        // textFieldRow가 자기 몫의 세로 패딩(spacing150)을 스스로 갖게 되면서, 박스 전체를
        // 감싸던 공용 세로 패딩이 없어졌다 — 답장 미리보기는 위쪽 여백을 직접 챙긴다.
        .padding(.top, Spacing.spacing150)
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
