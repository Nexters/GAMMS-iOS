//
//  SafariView.swift
//  GAMSS
//
//  Created by 이건준 on 8/12/26.
//

import SafariServices
import SwiftUI

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    
    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: Context
    ) {}
}
