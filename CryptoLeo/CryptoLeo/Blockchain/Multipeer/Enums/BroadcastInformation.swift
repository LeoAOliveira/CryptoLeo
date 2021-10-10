//
//  BroadcastInformation.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 08/10/21.
//

import Foundation

/// Possible informations to be broadcasted to multi-peer session.
///
/// The enum contains:
/// - Current `Blockchain`.
/// - New `Block` recently mined and added to blockchain.
/// - Newt `Transaction` available for mining.
enum BroadcastInformation {
    
    /// A custom `String` message.
    case message(String)
    
    /// Updated `Blockchain`.
    case updatedBlockchain(Blockchain)
    
    /// Recently mined and added `Block`.
    case newBlock(Block)
    
    /// Recently created `Transaction`.
    case newTransaction(Transaction)
}
