//
//  CodeGenerator.swift
//  
//
//  Created by Pete Schwamb on 5/1/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation
import CryptoKit

final public class CodeGenerator {

    let verifier: String
    let challenge: String

    public init() {
        var buffer = [UInt8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        if status != errSecSuccess {
            fatalError("failed to generate verifier")
        }

        verifier = Data(buffer).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)

        let ascii = verifier.data(using: .ascii)!

        challenge = Data(SHA256.hash(data: ascii))
            .base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .trimmingCharacters(in: .whitespaces)

    }
}
