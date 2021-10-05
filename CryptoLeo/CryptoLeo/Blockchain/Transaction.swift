//
//  Transaction.swift
//  Crypto Leo
//
//  Created by Leonardo Oliveira on 28/09/21.
//

import Foundation
import CryptoKit

final class Transaction {
    
    /// Peer that is sending the cryptocurrency.
    let sender: Peer
    
    /// Peer that is receiving the cryptocurrency.
    let receiver: Peer
    
    /// Amount of cryptocurrency that is being transacted.
    let amount: Double
    
    /// When the transaction is being made.
    let timestamp: Timestamp = Timestamp()
    
    /// Transaction message.
    private(set) lazy var message: String = createMessage()
    
    /// Signature that validates the transaction.
    private(set) var signature: Data? = nil
    
    /// Initializes a transaction.
    /// - Parameter sender: Peer that is sending the cryptocurrency. If it's s a mining reward, the value must be `nil`.
    /// - Parameter receiver: Peer that is receiving the cryptocurrency.
    /// - Parameter amount: Amount of cryptocurrency that is being transacted.
    /// - Parameter privateKey: Transaction author's private key, that will be used to sign the transaction.
    init(sender: Peer, receiver: Peer, amount: Double) {
        self.sender = sender
        self.receiver = receiver
        self.amount = amount
    }
    
    /// Signs the transaction.
    /// - Parameter privateKey: Transaction author's private key, that will be used to sign the transaction.
    /// - Parameter completion: Result of the signing.
    func sign(with privateKey: Curve25519.Signing.PrivateKey, completion: (Result<Bool, CryptoLeoError>) -> Void) {
        
        let signature = DigitalSignature.sign(message: message, privateKey: privateKey, publicKey: sender.publicKey)
        
        if signature != nil {
            self.signature = signature
            completion(.success(true))
            
        } else {
            completion(.failure(.failedToSignTransaction))
        }
    }
    
    /// Creates a message describing the transaction.
    /// - Returns: Message describing the transaction.
    private func createMessage() -> String {
        
        return "\(sender) pays \(receiver) L$ \(String(format: "%.2f", amount)) on \(timestamp.date)"
    }
}
