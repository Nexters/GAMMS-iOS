//
//  NonceGenerator.swift
//  GAMSS
//
//  Created by 이건준 on 7/21/26.
//

import CryptoKit
import Foundation

// MARK: - Reference
// Apple 로그인을 위한 Nonce 생성 및 SHA256 해싱 구현 참고
// https://firebase.google.com/docs/auth/ios/apple?hl=ko
enum NonceGenerator {
    static func generate(
        length: Int = 32
    ) -> String {
        
        precondition(length > 0)
        
        let charset = Array(
            "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._"
        )
        
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms = (0..<16).map { _ in
                UInt8.random(in: .min ... .max)
            }
            
            randoms.forEach { random in
                guard remainingLength > 0 else {
                    return
                }
                
                guard random < charset.count else {
                    return
                }
                
                result.append(
                    charset[Int(random)]
                )
                
                remainingLength -= 1
            }
        }
        
        return result
    }
    
    static func sha256(
        _ input: String
    ) -> String {
        
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(
            data: inputData
        )
        
        return hashedData
            .compactMap {
                String(
                    format: "%02x",
                    $0
                )
            }
            .joined()
    }
}
