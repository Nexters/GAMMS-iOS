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
                .frame(height: 150)
                .border(Color.gray.opacity(0.3))

            Button("일기 요약") {
                Task {
                    await viewModel.summarize(text: inputText)
                }
            }
            .disabled(viewModel.isLoading)

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
