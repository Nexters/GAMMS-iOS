//
//  ArchiveView.swift
//  GAMSS
//
//  Created by 이건준 on 8/18/26.
//

import SwiftUI

struct ArchiveView: View {
    @StateObject private var viewModel: ArchiveViewModel
    
    init(viewModel: ArchiveViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                    .padding(.bottom, 32)
                
                ScrollView {
                    VStack(alignment: .center, spacing: 34) {
                        Text("다시 보고 싶은 쓰레기통을 열어보세요")
                            .typography(.body4Medium)
                            .foregroundStyle(Color.colorGray950)
                            .padding(.bottom, 2)
                        
                        trashCanGrid
                    }
                    .padding(.bottom, 33)
                }
            }
            .background(Color.colorWhite)
        }
    }
}

private extension ArchiveView {
    var header: some View {
        HStack {
            Image("logoGamss")
                .resizable()
                .scaledToFit()
                .frame(height: 24)
            
            Spacer()
            
            Button {
                
            } label: {
                Image("gear")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.colorGray900)
            }
        }
        .frame(height: 64)
        .padding(.horizontal, 18)
    }
    
    var trashCanGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.fixed(132), spacing: 40),
                GridItem(.fixed(132), spacing: 40)
            ],
            spacing: 11
        ) {
            ForEach(viewModel.emotions) { emotion in
                NavigationLink {
                    ArchiveDetailView(
                        title: emotion.name,
                        viewModel: ArchiveDetailViewModel(
                            fetchCardsByDateUseCase: DefaultFetchCardsByDateUseCase(
                                cardRepository: DefaultCardRepository(networkManager: NetworkManager.shared),
                                emotion: emotion
                            )
                        )
                    )
                } label: {
                    TrashItemView(imageNamed: emotion.trashImageNamed)
                        .frame(width: 132, height: 172)
                }
            }
        }
    }
}

#Preview {
    ArchiveView(viewModel: ArchiveViewModel())
}
