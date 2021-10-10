//
//  BlockchainTransactor.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 05/10/21.
//

import Foundation
import CryptoKit

/// Object responsible to intermediate cryptocurrency transactions and to mine blocks into the blockchain.
final class BlockchainTransactor {
    
    // MARK: - Internal properties
    
    /// Closure called when peer finishes to mine the genesis block, creating the blockchain.
    var didCreateBlockchain: ((Blockchain) -> Void)?
    
    /// Closure called when the blockchain is updated.
    var didUpdateBlockchain: ((Blockchain) -> Void)?
    
    /// Closure called when cryptocurrency transaction is completed.
    var didTransferCrypto: ((Transaction) -> Void)?
    
    /// Closure called when a new block is added to blockchain.
    var didAddNewBlock: ((Block) -> Void)?
    
    /// Closure called when finishes to mine a given block.
    var didFinishMining: ((Block) -> Void)?
    
    /// The blockchain it self, containing all the blocks.
    private(set) var blockchain: Blockchain
    
    // MARK: - Private properties
    
    /// Number of zeros as hash's first characters, proof that the block has being mined (computational work put into to it),
    private let proofOfWork: String = "0000"
    
    /// User information modeled into the `Peer` struct, containing the user's name and public key.
    private let userPeer: Peer
    
    // MARK: - Initializers
    
    /// Initializes a `Transactor` by creating a blockchain and mining the genesis block (fist block to be added in the blockchain).
    /// - Parameter blockchainName: Name for the blockchain.
    /// - Parameter creator: Blockchain's creator.
    /// - Parameter session: Multipeer session that enables the communication between the peers.
    init(blockchainName: String, userPeer: Peer) {
        self.userPeer = userPeer
        self.blockchain = Blockchain(name: blockchainName, blocks: [])
        createGenesisBlock(miner: userPeer)
    }
    
    /// Initializes a `Transactor` by creating a blockchain and mining the genesis block (fist block to be added in the blockchain).
    /// - Parameter blockchainName: Name for the blockchain.
    /// - Parameter creator: Blockchain's creator.
    /// - Parameter session: Multipeer session that enables the communication between the peers.
    init(userPeer: Peer) {
        self.userPeer = userPeer
        self.blockchain = Blockchain(name: "", blocks: [])
    }
    
    // MARK: - Internal methods
    
    func updateBlockchain(with incomingBlockchain: Blockchain) {
        
        if incomingBlockchain.blocks.count > blockchain.blocks.count {
            blockchain = incomingBlockchain
            didUpdateBlockchain?(blockchain)
        }
    }
    
    func addBlockToBlockchain(block: Block) throws {
        
        guard let transaction = block.transaction else {
            throw CryptoLeoError.blockDoesNotHaveStoredTransaction
        }
        
        let messageData = Data(transaction.message.utf8)
        let signature = transaction.signature
        let senderPublicKey = transaction.sender.publicKey
        
        guard let publicKey = try? Curve25519.Signing.PublicKey(rawRepresentation: senderPublicKey),
              publicKey.isValidSignature(signature, for: messageData) else {
            
            throw CryptoLeoError.transactionSignatureIsInvalid
        }
        
        guard block.hash.hasPrefix(proofOfWork) else {
            throw CryptoLeoError.blockHasInvalidHash
        }
        
        blockchain.blocks.append(block)
        didAddNewBlock?(block)
    }
    
    /// Sends a cryptocurrency transaction to another peer.
    ///
    /// First, this method fetches the sender `Peer` model and it's personal private key from the `UserDefaults`.
    /// Then, a `Transaction` model is created, secured with a private-public key cryptographic signature.
    /// If `mineOwnBlock` parameter is `true`, the sender `Peer` will mine the own block.
    /// Else, the connected miners in the multi-peer session will be communicated that a new block is available for mining.
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
            mineBlock(transaction: transaction)
            
        } else {
            didTransferCrypto?(transaction)
        }
    }
    
    /// Performs computational work to mine a block.
    ///
    /// This method mines a block by iterating a nonce util the hash of the block's key
    /// (composed by index, previous block's hash, reward's message, transaction's message and nonce)
    /// has four zeros as the first four characters. When the mining computational work is done, the
    /// `completion` closure is called, passing the mined `Block` as parameter.
    ///
    /// - Parameter transaction: Transaction to be included in the block.
    func mineBlock(transaction: Transaction) {
        
        var nonce = 0
        
        let blocks = blockchain.blocks
        let previousHash = blocks[blocks.count-1].hash
        let index = blocks.count
        let timestamp = Timestamp.string()
        let message = "\(userPeer.name) gets L$ 5.00 for mining the block on \(timestamp)"
        
        let reward = Reward(miner: userPeer,
                            amount: 5,
                            timestamp: timestamp,
                            message: message)
        
        let ledger = createLedger(index: index,
                                  previousHash: previousHash,
                                  rewardMessage: reward.message,
                                  transactionMessage: transaction.message)
        
        var key: String {
            return ledger + "Nonce: \(nonce)"
        }
        
        var blockHash = createHash(key: key)
        
        while(!blockHash.hasPrefix(proofOfWork)) {
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
        
        blockchain.blocks.append(block)
        didFinishMining?(block)
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
                           timestamp: Timestamp.string(),
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
            self?.didCreateBlockchain?(blockchain)
        }
    }
    
    /// Performs computational work to mine the genesis block.
    ///
    /// This method mines the genesis block by iterating a nonce util the hash of the block's key
    /// (composed by index, message and nonce) has four zeros as the first four characters.
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
        
        while(!blockHash.hasPrefix(proofOfWork)) {
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
