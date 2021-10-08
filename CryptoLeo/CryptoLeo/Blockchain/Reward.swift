//
//  Reward.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 04/10/21.
//

import Foundation
import CryptoKit

/// Reward given to a miner (`Peer`) for mining a block into and add it to the blockchain.
///
/// - **Miner**: Peer responsible for performing the needed computational work to mine a block.
/// - **Amount**: Cryptocurrencies given as reward for mining a block.
/// - **Timestamp**: Date and time of the reward.
/// - **Message**: Description of the reward.
struct Reward {
    
    /// Peer that's being rewarded with cryptocurrency.
    let miner: Peer
    
    /// Amount of cryptocurrency that the miner is being rewarded with.
    let amount: Double = 5
    
    /// When the transaction is being made.
    let timestamp: String = Timestamp.string()
    
    /// Reward's description.
    let message: String
}
