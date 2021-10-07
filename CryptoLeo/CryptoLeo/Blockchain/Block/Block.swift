//
//  Block.swift
//  Crypto Leo
//
//  Created by Leonardo Oliveira on 03/10/21.
//

import Foundation
import CryptoKit

final class Block: BlockType, Codable {
    
    /// If the block is available for mining.
    var availableForMining: Bool = true
    
    /// Transaction included in the block.
    let transaction: Transaction?
    
    /// Reward given to the block's miner.
    private(set) var reward: Reward?
    
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
    
    /// Initializes a block.
    /// - Parameter transaction: Transaction that will be stored in the block.
    init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    /// Creates the block's ledger.
    /// - Parameter index: Block's position on the blockchain.
    /// - Parameter previousHash: Previous block's hash using SHA256 algorithm.
    /// - Parameter rewardMessage: Reward's message given to the block's miner.
    /// - Returns: Block's ledger, composed by the index, previous hash, transaction and  reward.
    private func createLedger(index: Int, previousHash: String, rewardMessage: String) -> String {
        
        var ledger: String = "Index: \(index)\n"
        ledger += "Previous hash: \(previousHash)\n"
        ledger += "Reward: \(rewardMessage)\n"
        
        if let transactionMessage = transaction?.message {
            ledger += "Transaction: \(transactionMessage)\n"
        } else {
            ledger += "Genesis: created on \(Timestamp.string())"
        }
        
        return ledger
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
    
    /// Perform computational work to mine the block.
    /// - Parameter previousIndex: Previous block's position on the blockchain.
    /// - Parameter previousHash: Previous block's hash using SHA256 algorithm.
    /// - Parameter miner: The peer that will mine the block.
    /// - Parameter privateKey: Miner's private key, that will be used to sign the reward transaction.
    /// - Parameter completion: Result of the computational work.
    func mine(previousIndex: Int,
              previousHash: String,
              miner: Peer,
              privateKey: Curve25519.Signing.PrivateKey,
              completion: (Result<Bool, CryptoLeoError>) -> Void) {
        
        if let transaction = self.transaction, transaction.signature == nil {
            completion(.failure(.transactionIsNotSigned))
            return
        }
        
        let index = previousIndex + 1
        let reward = Reward(miner: miner)
        let ledger = createLedger(index: index, previousHash: previousHash, rewardMessage: reward.message)
        
        self.index = index
        self.reward = reward
        self.previousHash = previousHash
        
        var blockHash = createHash(ledger: ledger, nonce: nonce)
        
        while(!blockHash.hasPrefix("0000") && availableForMining) {
            nonce += 1
            blockHash = createHash(ledger: ledger, nonce: nonce)
        }
        
        if availableForMining {
            hash = blockHash
            availableForMining = false
            completion(.success(true))
            
        } else {
            completion(.failure(.blockIsAlreadyMined))
        }
    }
}
