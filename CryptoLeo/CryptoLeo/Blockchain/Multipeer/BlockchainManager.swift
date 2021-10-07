//
//  BlockchainManager.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 05/10/21.
//

import Foundation
import CryptoKit
import MultipeerConnectivity

final class CryptoLeoTransactor {
    
    var didCreateBlockchain: (() -> Void)?
    var didTransferCrypto: (() -> Void)?
    var didFinishMining: (() -> Void)?
    
    private var blockchain: Blockchain
    private let session: MCSession
    
    init(name: String, creator: Peer, session: MCSession) {
        self.blockchain = Blockchain(name: name, blocks: [])
        self.session = session
        createGenesisBlock(miner: creator)
    }
    
    func sendTransaction(amount: Double,
                         receiver: Peer,
                         privateKey: Curve25519.Signing.PrivateKey,
                         mineOwnBlock: Bool) throws {
        
        let publicKey = privateKey.publicKey.rawRepresentation
        let sender = Peer(name: "Leo", publicKey: publicKey)
        
        guard let transaction = createTransaction(amount: amount, receiver: receiver, privateKey: privateKey) else {
            throw CryptoLeoError.failedToSignTransaction
        }
        
        if mineOwnBlock {
            
            print("MINING BLOCK...\n\n")
            
            mineBlock(miner: sender,
                      privateKey: privateKey,
                      transaction: transaction) { [weak self] block in
                
                self?.blockchain.blocks.append(block)
                
                print("BLOCKCHAIN:\n")
                for block in blockchain.blocks {
                    print("\(block.key)\n")
                }
            }
        }
    }
    
    private func createTransaction(amount: Double,
                                   receiver: Peer,
                                   privateKey: Curve25519.Signing.PrivateKey) -> Transaction? {
        
        let publicKey = privateKey.publicKey.rawRepresentation
        let sender = Peer(name: "Leo", publicKey: publicKey)
        
        let message = "\(sender.name) pays \(receiver.name) L$ \(String(format: "%.2f", amount)) on \(Timestamp.string())"
        
        guard let signature = sign(message: message, privateKey: privateKey, publicKey: publicKey) else {
            return nil
        }
        
        return Transaction(sender: sender,
                           receiver: receiver,
                           amount: amount,
                           message: message,
                           signature: signature)
    }
    
    private func sign(message: String,
                      privateKey: Curve25519.Signing.PrivateKey,
                      publicKey: Data) -> Data? {
        
        let messageData = Data(message.utf8)
        
        guard let signature = try? privateKey.signature(for: messageData),
              let signingPublicKey = try? Curve25519.Signing.PublicKey(rawRepresentation: publicKey),
              signingPublicKey.isValidSignature(signature, for: messageData) else {
            
            return nil
        }
        
        return signature
    }
    
    /// Creates the block's hash.
    /// - Parameter ledger: Block's ledger, composed by the index, previous hash, transaction and  reward.
    /// - Parameter nonce: Block's proof-of-work.
    /// - Returns: Block's hash using SHA256 algorithm.
    private func createHash(key: String) -> String {
        
        let data = Data(key.utf8)
        let digest = SHA256.hash(data: data)
        
        let hashElements = digest.compactMap {
            String(format: "%02x", $0)
        }
        
        let hash = hashElements.joined()
        
        return hash
    }
    
    private func createGenesisBlock(miner: Peer) {
        
        mineGenesisBlock(miner: miner) { [weak self] block in
            self?.blockchain.blocks.append(block)
            self?.didCreateBlockchain?()
        }
    }
    
    /// Perform computational work to mine the genesis block.
    /// - Parameter miner: The peer that will mine the block.
    /// - Parameter completion: Completion of the computational work.
    private func mineGenesisBlock(miner: Peer,
                                  completion: (Block) -> Void) {
        
        let ledger = "Index: 0\nMessage: Genesis Block, created by \(miner.name) on \(Timestamp.string())\n"
        
        var nonce = 0
        
        var key: String {
            return ledger + "Nonce: \(nonce)"
        }
        
        var blockHash = createHash(key: key)
        
        while(!blockHash.hasPrefix("00000")) {
            nonce += 1
            blockHash = createHash(key: key)
        }
        
        let genesisBlock = Block(transaction: nil,
                                 reward: nil,
                                 index: 0,
                                 hash: blockHash,
                                 previousHash: nil,
                                 nonce: nonce,
                                 key: key)
        
        completion(genesisBlock)
    }
    
    /// Perform computational work to mine the block.
    /// - Parameter miner: The peer that will mine the block.
    /// - Parameter privateKey: Miner's private key, that will be used to sign the reward transaction.
    /// - Parameter completion: Result of the computational work.
    func mineBlock(miner: Peer,
                   privateKey: Curve25519.Signing.PrivateKey,
                   transaction: Transaction,
                   completion: (Block) -> Void) {
        
        let blocks = blockchain.blocks
        let previousHash = blocks[blocks.count-1].hash
        let index = blocks.count
        var nonce = 0
        
        let message = "\(miner.name) gets L$ 5.00 for mining the block on \(Timestamp.string())"
        let reward = Reward(miner: miner, message: message)
        
        let ledger = createLedger(index: index,
                                  previousHash: previousHash,
                                  rewardMessage: reward.message,
                                  transactionMessage: transaction.message)
        
        var key: String {
            return ledger + "Nonce: \(nonce)"
        }
        
        var blockHash = createHash(key: key)
        
        while(!blockHash.hasPrefix("00000")) {
            nonce += 1
            blockHash = createHash(key: key)
        }
        
        let block = Block(transaction: transaction,
                          reward: reward,
                          index: index,
                          hash: blockHash,
                          previousHash: previousHash,
                          nonce: nonce,
                          key: key)
        
        completion(block)
    }
    
    /// Creates the block's ledger.
    /// - Parameter index: Block's position on the blockchain.
    /// - Parameter previousHash: Previous block's hash using SHA256 algorithm.
    /// - Parameter rewardMessage: Reward's message given to the block's miner.
    /// - Returns: Block's ledger, composed by the index, previous hash, transaction and  reward.
    private func createLedger(index: Int,
                              previousHash: String,
                              rewardMessage: String,
                              transactionMessage: String) -> String {
        
        var ledger: String = "Index: \(index)\n"
        
        ledger += "Previous hash: \(previousHash)\n"
        ledger += "Reward: \(rewardMessage)\n"
        ledger += "Transaction: \(transactionMessage)\n"
        
        return ledger
    }
}
