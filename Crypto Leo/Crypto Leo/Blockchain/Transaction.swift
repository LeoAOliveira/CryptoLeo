//
//  Transaction.swift
//  Crypto Leo
//
//  Created by Leonardo Oliveira on 28/09/21.
//

import Foundation
import CryptoKit

final class Transaction {
    
    /// Party that is sending the cryptocurrency.
    let sender: String?
    
    /// Party that is receiving the cryptocurrency.
    let receiver: String
    
    /// Amount of cryptocurrency that is being transacted.
    let amount: Double
    
    /// Date and time that the transaction is being made.
    let timestamp: String = {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        return dateFormatter.string(from: date)
    }()
    
    /// Transaction message.
    private(set) lazy var message: String = createMessage(sender: sender, receiver: receiver, amount: amount)
    
    /// Signature that validates the transaction.
    private(set) lazy var signature: SHA256Digest? = signTransaction(privateKey: privateKey)
    
    /// Transaction author's private key, that will be used to sign the transaction.
    private let privateKey: String
    
    /// Initializes a transaction.
    /// - Parameter sender: Party that is sending the cryptocurrency. If it's s a mining reward, the value must be `nil`.
    /// - Parameter receiver: Party that is receiving the cryptocurrency.
    /// - Parameter amount: Amount of cryptocurrency that is being transacted.
    /// - Parameter privateKey: Transaction author's private key, that will be used to sign the transaction.
    init(sender: String?, receiver: String, amount: Double, privateKey: String) {
        self.sender = sender
        self.receiver = receiver
        self.amount = amount
        self.privateKey = privateKey
    }
    
    /// Signs a transaction.
    /// - Parameter privateKey: Transaction author's private key, that will be used to sign the transaction.
    /// - Returns: Signature for this specific transaction.
    private func signTransaction(privateKey: String) -> SHA256Digest? {
        
        if let signatureData = (message + privateKey).data(using: .utf8) {
            return SHA256.hash(data: signatureData)
        }
        
        return nil
    }
    
    /// Creates a message describing the transaction.
    /// - Parameter sender: Party that is sending the cryptocurrency. If it's s a mining reward, the value must be `nil`.
    /// - Parameter receiver: Party that is receiving the cryptocurrency.
    /// - Parameter amount: Amount of cryptocurrency that is being transacted.
    /// - Returns: Message describing the transaction.
    private func createMessage(sender: String?, receiver: String, amount: Double) -> String {
        
        if let sender = sender {
            return "\(sender) pays \(receiver) L$\(String(format: "%.2f", amount)) on \(timestamp)"
        }
        
        return "\(receiver) gets L$\(String(format: "%.2f", amount)) for mining the block on \(timestamp)"
    }
}
