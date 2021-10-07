//
//  BlockType.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 05/10/21.
//

import Foundation
import CryptoKit

protocol BlockType: Codable {
    
    /// Transaction included in the block.
    var transaction: Transaction? { get }
    
    /// Block's position on the blockchain.
    var index: Int? { get }
    
    /// Block's hash using SHA256 algorithm.
    var hash: String? { get }
    
    /// Previous block's hash using SHA256 algorithm.
    var previousHash: String? { get }
    
    /// Proof-of-work that must be incremented until a value is found that gives the block's hash the required zero bits..
    var nonce: Int { get }
    
    /// Block's key, composed by the index, previous hash, transaction, reward and nonce.
    var key: String { get }
}
