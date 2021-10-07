//
//  Reward.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 04/10/21.
//

import Foundation
import CryptoKit

struct Reward {
    
    /// Peer that's being rewarded with cryptocurrency.
    let miner: Peer
    
    /// Amount of cryptocurrency that the miner is being rewarded with.
    let amount: Double = 5
    
    /// When the transaction is being made.
    let timestamp: String = Timestamp.string()
    
    /// Reward message.
    let message: String
}
