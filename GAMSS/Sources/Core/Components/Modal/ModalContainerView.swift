//
//  ModalContainerView.swift
//  GAMSS
//
//  Created by 이건준 on 8/4/26.
//

import SwiftUI

struct ModalContainerView<Content: View>: View {
    @Binding private var isPresented: Bool
    
    private let dismissOnBackgroundTap: Bool
    private let content: () -> Content
    
    init(
        isPresented: Binding<Bool>,
        dismissOnBackgroundTap: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.dismissOnBackgroundTap = dismissOnBackgroundTap
        self.content = content
    }
    
    var body: some View {
        ZStack {
            Color.colorBlack
                .opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    guard dismissOnBackgroundTap else { return }
                    
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isPresented = false
                    }
                }
            
            content()
                .transition(.scale.combined(with: .opacity))
                .padding(.horizontal, 28)
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
}
