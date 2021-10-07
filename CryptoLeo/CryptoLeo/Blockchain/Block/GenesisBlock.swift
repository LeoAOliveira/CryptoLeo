//
//  GenesisBlock.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 05/10/21.
//

import Foundation
import CryptoKit

final class GenesisBlock: BlockType {
    
    /// Transaction included in the block.
    let transaction: Transaction?
    
    /// Block's position on the blockchain.
    private(set) var index: Int?
    
    /// Block's hash using SHA256 algorithm.
    private(set) var hash: String?
    
    /// Previous block's hash using SHA256 algorithm.
    private(set) var previousHash: String?
    
    /// Proof-of-work that must be incremented until a value is found that gives the block's hash the required zero bits. Initial value is `0`.
    private(set) var nonce: Int = 0
    
    /// Block's key, composed by the index, previous hash, transaction, reward and nonce.
    private(set) var key: String = ""
    
    /// Initializes a genesis block.
    init() {
        index = 0
        transaction = nil
        previousHash = nil
    }
    
    /// Creates the block's hash.
    /// - Parameter ledger: Block's ledger, composed by the index, previous hash, transaction and  reward.
    /// - Parameter nonce: Block's proof-of-work.
    /// - Returns: Block's hash using SHA256 algorithm.
    private func createHash(ledger: String, nonce: Int) -> String {
        
        key = ledger + "Nonce: \(nonce)"
        
        let data = Data(key.utf8)
        let digest = SHA256.hash(data: data)
        
        let hashElements = digest.compactMap {
            String(format: "%02x", $0)
        }
        
        let hash = hashElements.joined()
        
        return hash
    }
    
    /// Perform computational work to mine the genesis block.
    /// - Parameter miner: The peer that will mine the block.
    /// - Parameter completion: Completion of the computational work.
    func mine(miner: Peer, completion: () -> Void) {
        
        let ledger = "Index: 0\nMessage: Genesis Block, create by \(miner.name) on \(Timestamp.string())\n"
        
        var blockHash = createHash(ledger: ledger, nonce: nonce)
        
        while(!blockHash.hasPrefix("0000")) {
            nonce += 1
            blockHash = createHash(ledger: ledger, nonce: nonce)
        }
        
        hash = blockHash
        completion()
    }
}
