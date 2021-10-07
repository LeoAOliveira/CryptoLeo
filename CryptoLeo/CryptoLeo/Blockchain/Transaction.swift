//
//  Transaction.swift
//  Crypto Leo
//
//  Created by Leonardo Oliveira on 28/09/21.
//

import Foundation
import CryptoKit

final class Transaction: Codable {
    
    /// Peer that is sending the cryptocurrency.
    let sender: Peer
    
    /// Peer that is receiving the cryptocurrency.
    let receiver: Peer
    
    /// Amount of cryptocurrency that is being transacted.
    let amount: Double
    
    /// When the transaction is being made.
    let timestamp: String
    
    /// Transaction message.
    private(set) lazy var message: String = createMessage()
    
    /// Signature that validates the transaction.
    private(set) var signature: Data? = nil
    
    /// Initializes a transaction.
    /// - Parameter sender: Peer that is sending the cryptocurrency. If it's s a mining reward, the value must be `nil`.
    /// - Parameter receiver: Peer that is receiving the cryptocurrency.
    /// - Parameter amount: Amount of cryptocurrency that is being transacted.
    /// - Parameter privateKey: Transaction sender's private key, that will be used to sign the transaction.
    init(sender: Peer, receiver: Peer, amount: Double) {
        self.sender = sender
        self.receiver = receiver
        self.amount = amount
        self.timestamp = Timestamp.string()
    }
    
    /// Signs the transaction.
    /// - Parameter message: Transaction's message.
    /// - Parameter privateKey: Transaction sender's private key, that will be used to sign the transaction.
    /// - Parameter publicKey: Transaction sender's public key, that will be used to validate the signature.
    /// - throws: Transaction signing error.
    func sign(privateKey: Curve25519.Signing.PrivateKey, publicKey: Data) throws {
        
        let messageData = Data(message.utf8)
        
        guard let signature = try? privateKey.signature(for: messageData),
              let signingPublicKey = try? Curve25519.Signing.PublicKey(rawRepresentation: publicKey),
              signingPublicKey.isValidSignature(signature, for: messageData) else {
            
            throw CryptoLeoError.failedToSignTransaction
        }
        
        self.signature = signature
    }
    
    /// Creates a message describing the transaction.
    /// - Returns: Message describing the transaction.
    private func createMessage() -> String {
        return "\(sender.name) pays \(receiver.name) L$ \(String(format: "%.2f", amount)) on \(timestamp)"
    }
}
