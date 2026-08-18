//
//  ArchiveDetailView.swift
//  GAMSS
//
//  Created by 이건준 on 8/18/26.
//

import SwiftUI
import SpriteKit

struct ArchiveDetailView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ArchiveDetailViewModel
    @State private var scene = DropStackScene()
    @State private var isMonthPickerPresented = false

    private let title: String

    init(
        title: String,
        viewModel: ArchiveDetailViewModel
    ) {
        self.title = title
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 18)
                .padding(.vertical, Spacing.spacing400)

            monthSelector
                .padding(.horizontal, 18)
                .padding(.bottom, Spacing.spacing300)

            ZStack {
                Color.colorWhite

                GeometryReader { proxy in
                    SpriteView(scene: scene, options: [.allowsTransparency])
                        .onAppear {
                            scene.scaleMode = .resizeFill
                            scene.updateSize(proxy.size)
                            scene.render(notes: viewModel.notes)
                        }
                        .onChange(of: proxy.size) { _, newSize in
                            scene.updateSize(newSize)
                        }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.colorWhite)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .alert(
            viewModel.errorMessage ?? "",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("확인", role: .cancel) {}
        }
        .task {
            await viewModel.load()
        }
        .onChange(of: viewModel.notes) { _, notes in
            scene.render(notes: notes)
        }
        .sheet(isPresented: $isMonthPickerPresented) {
            ArchiveDatePickerSheet(selectedMonth: viewModel.selectedMonth) { month in
                Task {
                    await viewModel.selectMonth(month)
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: Spacing.spacing200) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.colorGray900)
            }

            Text(title)
                .typography(.subtitle2)
                .foregroundStyle(Color.colorGray900)

            Spacer()

            Button("비우기") {
                viewModel.clearNotes()
                scene.clear()
            }
            .typography(.body5Medium)
            .foregroundStyle(Color.colorGray900)
        }
    }

    private var monthSelector: some View {
        Button {
            isMonthPickerPresented = true
        } label: {
            HStack {
                Text(DateFormatterFactory.dateWithDot.string(from: viewModel.selectedMonth))
                    .typography(.subtitle2)
                    .foregroundStyle(Color.colorGray900)

                Spacer()

                Image(systemName: "chevron.down")
                    .frame(width: 32, height: 32)
                    .foregroundStyle(Color.colorGray900)
            }
            .padding(.horizontal, Spacing.spacing200)
            .frame(height: 48)
            .overlay {
                Rectangle()
                    .stroke(Color.colorGray900, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }
}
