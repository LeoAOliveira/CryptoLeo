//
//  Block.swift
//  Crypto Leo
//
//  Created by Leonardo Oliveira on 03/10/21.
//

import Foundation

struct Block {
    
    /// Transaction included in the block.
    let transaction: Transaction?
    
    /// Reward given to the block's miner.
    let reward: Reward?
    
    /// Block's position on the blockchain.
    let index: Int
    
    /// Block's hash using SHA256 algorithm.
    let hash: String
    
    /// Previous block's hash using SHA256 algorithm.
    let previousHash: String?
    
    /// Proof-of-work that must be incremented until a value is found that gives the block's hash the required zero bits.
    let nonce: Int
    
    /// Block's key, composed by the index, previous hash, transaction, reward and nonce.
    let key: String
}
