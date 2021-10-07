//
//  Reward.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 04/10/21.
//

import Foundation
import CryptoKit

final class Reward: Codable {
    
    /// Peer that's being rewarded with cryptocurrency.
    let miner: Peer
    
    /// Amount of cryptocurrency that the miner is being rewarded with.
    let amount: Double
    
    /// When the transaction is being made.
    let timestamp: String
    
    /// Reward message.
    private(set) lazy var message: String = createMessage()
    
    /// Initializes a reward.
    /// - Parameter miner: Peer that's being rewarded with cryptocurrency.
    init(miner: Peer) {
        self.miner = miner
        self.amount = 10
        self.timestamp = Timestamp.string()
    }
    
    /// Creates a message describing the reward.
    /// - Returns: Message describing the reward.
    private func createMessage() -> String {
        return "\(miner.name) gets L$ \(amount) for mining the block on \(timestamp)"
    }
}
