//
//  Transaction.swift
//  Crypto Leo
//
//  Created by Leonardo Oliveira on 28/09/21.
//

import Foundation

/// Transaction of cryptocurrency between two `Peers`.
///
/// - **Sender**: Peer responsible for performing the needed computational work to mine a block.
/// - **Receiver**: Cryptocurrencies given as reward for mining a block.
/// - **Amount**: Cryptocurrencies given as reward for mining a block.
/// - **Timestamp**: Date and time of the transaction.
/// - **Message**: Description of the transaction.
/// - **Signature**: Unique digital signature (private-public key cryptography) that signed the transaction.
struct Transaction: Codable, Equatable {
    
    /// Peer that is sending the cryptocurrency.
    let sender: Peer
    
    /// Peer that is receiving the cryptocurrency.
    let receiver: Peer
    
    /// Amount of cryptocurrency that is being transacted.
    let amount: Double
    
    /// When the transaction is being made.
    let timestamp: String
    
    /// Transaction message.
    let message: String
    
    /// Signature that validates the transaction.
    let signature: Data
}
