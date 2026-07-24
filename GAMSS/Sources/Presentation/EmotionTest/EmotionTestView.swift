//
//  EmotionTestView.swift
//  GAMSS
//
//  Created by cchanmi on 7/25/26.
//

import SwiftUI

struct EmotionTestView: View {
    @StateObject private var viewModel: EmotionTestViewModel
    @State private var inputText: String = ""

    init(viewModel: EmotionTestViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextEditor(text: $inputText)
                .frame(height: 150)
                .border(Color.gray.opacity(0.3))

            Button("감정 분석") {
                Task {
                    await viewModel.analyze(text: inputText)
                }
            }
            .disabled(viewModel.isLoading)

            if viewModel.isLoading {
                ProgressView()
            }

            if let result = viewModel.result {
                Text("결과: \(result.emotion.rawValue) (확신도 \(String(format: "%.2f", result.confidence)))")
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
