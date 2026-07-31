//
//  SummaryTestView.swift
//  GAMSS
//
//  Created by cchanmi on 7/31/26.
//

import SwiftUI

struct SummaryTestView: View {
    @StateObject private var viewModel: SummaryTestViewModel
    @State private var inputText: String = ""

    init(viewModel: SummaryTestViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextEditor(text: $inputText)
                .frame(height: 100)
                .border(Color.gray.opacity(0.3))

            HStack {
                Button("전송") {
                    Task {
                        await viewModel.addUtterance(inputText)
                        inputText = ""
                    }
                }
                .disabled(viewModel.isLoading || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Button("대화 종료") {
                    Task {
                        await viewModel.finalizeSession()
                    }
                }
                .disabled(viewModel.isLoading)
            }

            if !viewModel.utterances.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("누적된 발화")
                        .font(.subheadline)
                        .bold()
                    ForEach(Array(viewModel.utterances.enumerated()), id: \.offset) { _, utterance in
                        Text("- \(utterance)")
                    }
                }
            }

            if viewModel.isLoading {
                ProgressView()
            }

            if let result = viewModel.result {
                Text("결과: \(result)")
                    .font(.headline)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .padding()
    }
}
