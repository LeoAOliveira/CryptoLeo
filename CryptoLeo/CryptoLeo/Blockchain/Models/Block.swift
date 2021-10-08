//
//  Block.swift
//  Crypto Leo
//
//  Created by Leonardo Oliveira on 03/10/21.
//

import Foundation

/// Blockchain's block.
///
/// A blocks contains:
/// - **Index**: Position in the blockchain.
/// - **Hash**: Unique hash (using SHA256 algorithm) that identifies the block and the computational proof-of-work put into it.
/// - **Previous Hash**: Reference to the previous block hash (using SHA256 algorithm) in the blockchain.
/// - **Transaction**:  Transaction registered in the block.
/// - **Reward**:  Reward given to the block's miner for the computational work effort.
/// - **Key**:  Unique key with all the block's information, composed by index, previous hash, transaction, reward and nonce.
/// - **Nonce**:  Proof-of-work that must be incremented until a value is found that gives the block's hash the required zero bits.
struct Block: Codable, Equatable {
    
    /// Block's position on the blockchain.
    let index: Int
    
    /// Block's hash using SHA256 algorithm.
    let hash: String
    
    /// Previous block's hash using SHA256 algorithm.
    let previousHash: String?
    
    /// Transaction included in the block.
    let transaction: Transaction?
    
    /// Reward given to the block's miner.
    let reward: Reward?
    
    /// Block's key, composed by the index, previous hash, transaction, reward and nonce.
    let key: String
    
    /// Proof-of-work that must be incremented until a value is found that gives the block's hash the required zero bits.
    let nonce: Int
}
