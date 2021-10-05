//
//  DigitalSignature.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 04/10/21.
//

import Foundation
import CryptoKit

struct DigitalSignature {
    
    /// Signs a document.
    /// - Parameter message: Document's message.
    /// - Parameter privateKey: Document author's private key, that will be used to sign the document.
    /// - Parameter publicKey: Document author's public key, that will be used to validate the signature.
    /// - Returns: Signature for the specific given document.
    static func sign(message: String, privateKey: Curve25519.Signing.PrivateKey, publicKey: Data) -> Data? {
        
        let messageData = Data(message.utf8)
        
        guard let privateKeySignature = try? privateKey.signature(for: messageData),
              let signingPublicKey = try? Curve25519.Signing.PublicKey(rawRepresentation: publicKey),
              signingPublicKey.isValidSignature(privateKeySignature, for: messageData) else {
            
            return nil
        }
        
        return privateKeySignature
    }
}
