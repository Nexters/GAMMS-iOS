//
//  LoginView.swift
//  GAMSS
//
//  Created by 이건준 on 7/12/26.
//

import AuthenticationServices
import SwiftUI

struct LoginView: View {
    var body: some View {
        
        // FIXME: 소셜로그인관련 Mock 버튼 추후 수정
        VStack(alignment: .center) {
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [
                    .fullName,
                    .email
                ]
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    guard let credential = authorization.credential
                            as? ASAuthorizationAppleIDCredential
                    else {
                        return
                    }
                    
                    let userIdentifier = credential.user
                    let email = credential.email
                    let fullName = credential.fullName
                    let identityToken = credential.identityToken
                    let authorizationCode = credential.authorizationCode
                    
                    Log.debug("사용자고유ID: \(userIdentifier)")
                    Log.debug("이메일: \(email)")
                    Log.debug("풀이름: \(fullName)")
                    
                    if let identityToken,
                       let token = String(data: identityToken,
                                          encoding: .utf8) {
                        
                        Log.debug("토큰: \(token)")
                    }
                    
                    if let authorizationCode,
                       let code = String(data: authorizationCode,
                                         encoding: .utf8) {
                        
                        Log.debug("인증코드: \(code)")
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
