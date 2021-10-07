//
//  Transaction.swift
//  Crypto Leo
//
//  Created by Leonardo Oliveira on 28/09/21.
//

import Foundation

struct Transaction {
    
    /// Peer that is sending the cryptocurrency.
    let sender: Peer
    
    /// Peer that is receiving the cryptocurrency.
    let receiver: Peer
    
    /// Amount of cryptocurrency that is being transacted.
    let amount: Double
    
    /// When the transaction is being made.
    let timestamp: String = Timestamp.string()
    
    /// Transaction message.
    let message: String
    
    /// Signature that validates the transaction.
    let signature: Data
}
