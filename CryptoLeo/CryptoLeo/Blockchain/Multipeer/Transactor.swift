//
//  Transactor.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 05/10/21.
//

import Foundation
import CryptoKit
import MultipeerConnectivity

/// Object responsible to intermediate cryptocurrency transactions and to mine blocks into the blockchain.
final class Transactor {
    
    // MARK: - Internal properties
    
    /// Closure called when peer finishes to mine the genesis block, creating the blockchain.
    var didCreateBlockchain: (() -> Void)?
    
    /// Closure called when cryptocurrency transaction is completed.
    var didTransferCrypto: (() -> Void)?
    
    /// Closure called when finishes to mine a given block.
    var didFinishMining: (() -> Void)?
    
    // MARK: - Private properties
    
    /// The blockchain it self, containing all the blocks.
    private var blockchain: Blockchain
    
    /// Multipeer session that enables the communication between the peers.
    private let session: MCSession
    
    // MARK: - Initializers
    
    /// Initializes a Transactor by creating a blockchain and mining the genesis block (fist block to be added in the blockchain).
    /// - Parameter name: Name for the blockchain.
    /// - Parameter creator: Blockchain's creator.
    /// - Parameter session: Multipeer session that enables the communication between the peers.
    init(name: String, creator: Peer, session: MCSession) {
        self.blockchain = Blockchain(name: name, blocks: [])
        self.session = session
        createGenesisBlock(miner: creator)
    }
    
    // MARK: - Internal methods
    
    /// Sends a cryptocurrency transaction to another peer.
    ///
    /// First, this method fetches the sender `Peer` model and it's personal private key from the `UserDefaults`.
    /// Then, a `Transaction` model is created, secured with a private-public key cryptographic signature.
    /// If `mineOwnBlock` parameter is `true`, the sender `Peer` will mine the own block.
    /// Else, the connected miners in the multipeer session will be communicated that a new block is available for mining.
    ///
    /// - Parameter amount: Amount of cryptocurrency to be transfer.
    /// - Parameter receiver: Peer that will receive the amount to be transferred.
    /// - Parameter mineOwnBlock: Boolean describing if the sender will mine the own transaction block.
    /// - throws: A `CryptoLeoError` with an error description.
    func sendTransaction(amount: Double,
                         receiver: Peer,
                         mineOwnBlock: Bool) throws {
        
        let privateKey = Curve25519.Signing.PrivateKey()
        let publicKey = privateKey.publicKey.rawRepresentation
        let sender = Peer(name: "Leo", publicKey: publicKey)
        
        guard let transaction = createTransaction(amount: amount,
                                                  sender: sender,
                                                  receiver: receiver,
                                                  privateKey: privateKey) else {
            throw CryptoLeoError.failedToSignTransaction
        }
        
        if mineOwnBlock {
            
            print("MINING BLOCK...\n\n")
            
            mineBlock(miner: sender, transaction: transaction) { [weak self] block in
                
                self?.blockchain.blocks.append(block)
                
                print("BLOCKCHAIN:\n")
                for block in blockchain.blocks {
                    print("\(block.key)\n")
                }
            }
        }
    }
    
    /// Performs computational work to mine a block.
    ///
    /// This method mines a block by iterating a nonce util the hash of the block's key
    /// (composed by index, previous block's hash, reward's message, transaction's message and nonce)
    /// has five zeros as the first five characters. When the mining computational work is done, the
    /// `completion` closure is called, passing the mined `Block` as parameter.
    ///
    ///
    /// - Parameter miner: Peer that will mine the block.
    /// - Parameter transaction: Transaction to be included in the block.
    /// - Parameter completion: Block resulted from the computational work.
    func mineBlock(miner: Peer,
                   transaction: Transaction,
                   completion: (Block) -> Void) {
        
        var nonce = 0
        
        let blocks = blockchain.blocks
        let previousHash = blocks[blocks.count-1].hash
        let index = blocks.count
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
        
        let block = Block(index: index,
                          hash: blockHash,
                          previousHash: previousHash,
                          transaction: transaction,
                          reward: reward,
                          key: key,
                          nonce: nonce)
        
        completion(block)
    }
    
    // MARK: - Private methods
    
    /// Creates a transaction.
    ///
    /// First, the method creates the transaction's message, describing the amount of cryptocurrency, the peers involved
    /// in and the timestamp. Then, the message is signed by the transaction's sender using a private-public key
    /// cryptographic digital signature. The signing process may fail, and in this case the method returns `nil`.
    /// As the message is signed, a `Transaction` model is created and returned.
    ///
    /// - Parameter amount: Amount of cryptocurrency to be transfer.
    /// - Parameter sender: Peer that is sending the cryptocurrency amount.
    /// - Parameter receiver: Peer that will receive the amount to be transferred.
    /// - Parameter privateKey: Sender peer's private key, that will be used to sign the transaction.
    /// - Returns: A signed transaction.
    private func createTransaction(amount: Double,
                                   sender: Peer,
                                   receiver: Peer,
                                   privateKey: Curve25519.Signing.PrivateKey) -> Transaction? {
        
        let message = "\(sender.name) pays \(receiver.name) L$ \(String(format: "%.2f", amount)) on \(Timestamp.string())"
        
        guard let signature = sign(message: message, privateKey: privateKey, publicKey: sender.publicKey) else {
            return nil
        }
        
        return Transaction(sender: sender,
                           receiver: receiver,
                           amount: amount,
                           message: message,
                           signature: signature)
    }
    
    /// Signs a transaction.
    ///
    /// First, the message to be signed is turned into `Data`. As the casting is made, the data is signed using the
    /// sender's private key. After, the signature is validated using the signing public key and the message's data.
    /// If any of this processes (signing or validation) fails, the method returns `nil`. Else, the method returns the signature.
    ///
    /// - Parameter message: Message describing the transfer.
    /// - Parameter privateKey: Sender peer's private key, that will be used to sign the transaction.
    /// - Parameter publicKey: Sender peer's public key, that will be used to validate the signature..
    /// - Returns: Signature to the specific given transaction.
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
    
    /// Creates a block's ledger.
    ///
    /// The ledger is created by appending the block's index, previous
    /// block's hash, mining reward message and transaction message.
    ///
    /// - Parameter index: Block's position on the blockchain.
    /// - Parameter previousHash: Previous block's hash using SHA256 algorithm.
    /// - Parameter rewardMessage: Reward's message, describing a reward given to the block's miner.
    /// - Parameter transactionMessage: Transaction's message.
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
    
    /// Creates a block's hash.
    ///
    /// The hash is created by converting the block's key into `Data` and hashing it using SHA256 algorithm.
    /// Then, the hash digest is converted into string, to make the initial zeros further validation possible.
    ///
    /// - Parameter key: Block's key, composed by the index, previous hash, transaction, reward and nonce.
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
    
    /// Creates the blockchain's genesis block.
    ///
    /// Mines the genesis block and, when it's done, adds it to the empty
    /// blockchain and calls `didCreateBlockchain` closure.
    ///
    /// - Parameter miner: Peer that will mine the genesis block.
    private func createGenesisBlock(miner: Peer) {
        
        mineGenesisBlock(miner: miner) { [weak self] block in
            self?.blockchain.blocks.append(block)
            self?.didCreateBlockchain?()
        }
    }
    
    /// Performs computational work to mine the genesis block.
    ///
    /// This method mines the genesis block by iterating a nonce util the hash of the block's key
    /// (composed by index, message and nonce) has five zeros as the first five characters.
    /// When the mining computational work is done, the `completion` closure is called,
    /// passing the mined `Block` as parameter.
    ///
    /// - Parameter miner: Peer that will mine the genesis block.
    /// - Parameter completion: Genesis block resulted from the computational work.
    private func mineGenesisBlock(miner: Peer, completion: (Block) -> Void) {
        
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
        
        let genesisBlock = Block(index: 0,
                                 hash: blockHash,
                                 previousHash: nil,
                                 transaction: nil,
                                 reward: nil,
                                 key: key,
                                 nonce: nonce)
        
        completion(genesisBlock)
    }
}
