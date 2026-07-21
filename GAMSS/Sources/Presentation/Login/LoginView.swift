//
//  LoginView.swift
//  GAMSS
//
//  Created by 이건준 on 7/12/26.
//

import AuthenticationServices
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @State private var currentNonce: String?
    
    init(viewModel: LoginViewModel) {
        _viewModel = StateObject(
            wrappedValue: viewModel
        )
    }
    
    var body: some View {
        
        // FIXME: 소셜로그인관련 Mock 버튼 추후 수정
        VStack(alignment: .center) {
            SignInWithAppleButton(.signIn) { request in
                let nonce = NonceGenerator.generate()
                currentNonce = nonce
                
                request.requestedScopes = [
                    .fullName,
                    .email
                ]
                
                request.nonce = NonceGenerator.sha256(nonce)
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    guard let credential = authorization.credential
                            as? ASAuthorizationAppleIDCredential,
                          let nonce = currentNonce
                    else {
                        return
                    }
                    
                    Task {
                        await viewModel.login(
                            with: .apple,
                            credential: credential,
                            nonce: nonce
                        )
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
