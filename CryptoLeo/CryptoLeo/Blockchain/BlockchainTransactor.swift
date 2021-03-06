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
    
    /// Closure called when a new block is added to blockchain.
    var didAddNewBlock: ((Block) -> Void)?
    
    /// Closure called when starts mining a given block.
    var didStartMining: ((Block) -> Void)?
    
    /// Closure called when finishes mining a given block.
    var didFinishMining: ((Block) -> Void)?
    
    /// Closure called when proof-of-work value changes.
    var didUpdateProofOfWork: ((String) -> Void)?
    
    /// The blockchain it self, containing all the blocks.
    private(set) var blockchain: Blockchain
    
    // MARK: - Private properties
    
    /// Number of zeros as hash's first characters, cryptographic proof
    /// that the block has being mined (computational work put into to it),
    private let proofOfWork: String = "0000"
    
    /// User information modeled into the `Peer` struct, containing the user's name and public key.
    private let userPeer: Peer
    
    // MARK: - Initializers
    
    /// Initializes a `Transactor` by creating an empty blockchain. If `sessionRole` is `.host`
    /// it starts mining the genesis block in a background thread (first block to be added in the blockchain).
    /// - Parameter sessionRole: Role that the user has in the multi-peer session.
    /// - Parameter userPeer: User information modeled into `Peer`.
    init(sessionRole: SessionRole, userPeer: Peer) {
        
        self.userPeer = userPeer
        self.blockchain = Blockchain(name: "Blockchain", blocks: [])
        
        if sessionRole == .host {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.mineGenesisBlock(miner: userPeer)
            }
        }
    }
    
    // MARK: - Internal methods
    
    /// Updates the stored blockchain with a received updated version.
    ///
    /// If the incoming blockchain has more blocks than the currently stored blockchain, it updates the blockchain
    /// and calls `didUpdateBlockchain` event closure with the updated blockchain as parameter.
    ///
    /// - Parameter incomingBlockchain: Received blockchain, sent by another connected peer.
    func updateBlockchain(with incomingBlockchain: Blockchain) {
        
        if incomingBlockchain.blocks.count > blockchain.blocks.count {
            blockchain = incomingBlockchain
            didUpdateBlockchain?(blockchain)
        }
    }
    
    /// Adds the given block to blockchain.
    ///
    /// This method validates 3 essential information before adding the given block to blockchain:
    /// 1. Validates if there is a transaction stored inside the block. If it doesn't have one, a
    /// `.blockDoesNotHaveStoredTransaction` error is thrown.
    /// 2. Validates the veracity of the digital signature (using private-public key cryptography)
    /// attached to the transaction. If is invalid, it throws a `transactionSignatureIsInvalid` error.
    /// 3. Validates if the 4 first hash characters are all zeros, meaning that the block as been mined
    /// as proof-of-work. If there aren't, a `.blockHasInvalidHash` error is thrown.
    ///
    /// - Parameter block: Received block, sent by another connected peer.
    /// - throws: An `CryptoLeoError` describing the validation failure.
    func addBlockToBlockchain(block: Block) throws {
        
        guard let transaction = block.transaction else {
            throw CryptoLeoError.blockDoesNotHaveStoredTransaction
        }
        
        let messageData = Data(transaction.message.utf8)
        let signature = transaction.signature
        
        guard let senderPublicKey = transaction.sender.publicKey,
              let publicKey = try? Curve25519.Signing.PublicKey(rawRepresentation: senderPublicKey),
              publicKey.isValidSignature(signature, for: messageData) else {
            
            throw CryptoLeoError.transactionSignatureIsInvalid
        }
        
        guard block.hash.hasPrefix(proofOfWork) else {
            throw CryptoLeoError.blockHasInvalidHash
        }
        
        blockchain.blocks.append(block)
        didAddNewBlock?(block)
    }
    
    /// Creates a `Transaction` model with the given informations.
    ///
    /// First, this method fetches the sender `Peer` model and it's personal private key from the `UserDefaults`.
    /// Then, a `Transaction` model is created, secured with a private-public key cryptographic signature and
    /// returned.
    ///
    /// - Parameter amount: Amount of cryptocurrency to be transfer.
    /// - Parameter receiver: Peer that will receive the amount to be transferred.
    /// - Returns: A `Transaction` model.
    /// - throws: A `CryptoLeoError` with an error description.
    func createTransaction(amount: Double, receiver: Peer) throws -> Transaction {
        
        let privateKey = Curve25519.Signing.PrivateKey()
        let publicKey = privateKey.publicKey.rawRepresentation
        let sender = Peer(name: userPeer.name, uuid: userPeer.uuid, publicKey: publicKey)
        
        guard let transaction = createTransaction(amount: amount,
                                                  sender: sender,
                                                  receiver: receiver,
                                                  privateKey: privateKey) else {
            throw CryptoLeoError.failedToSignTransaction
        }
        
        return transaction
    }
    
    /// Performs computational work to mine a block.
    ///
    /// This method mines a block by iterating a nonce util the hash of the block's key (composed by index,
    /// previous block's hash, reward's message, transaction's message and nonce) has 4 zeros as the first 4
    /// characters. Due to this intense processing, the iteration is made in a background thread. During the hash
    /// processing, the `didUpdateProofOfWork` closure is called (in the main thread) when the nonce is
    /// divisible by 5000. When the mining computational work is done, the resulting block is added to the blockchain
    /// and the `didCreateBlockchain` and `didUpdateProofOfWork` closures are called in the main thread,
    /// passing the mined `Block` as parameter.
    ///
    /// - Parameter transaction: Transaction to be included in the block.
    func mineBlock(transaction: Transaction) {
        
        var nonce = 0
        
        let blocks = blockchain.blocks
        let previousHash = blocks[blocks.count-1].hash
        let index = blocks.count
        let timestamp = Timestamp.string()
        let message = "\(userPeer.name) ganhou L$ 5.00 por minerar o bloco em \(timestamp)"
        
        let reward = Reward(miner: userPeer,
                            amount: 5,
                            timestamp: timestamp,
                            message: message)
        
        let ledger = createLedger(index: index,
                                  previousHash: previousHash,
                                  rewardMessage: reward.message,
                                  transactionMessage: transaction.message)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            var key: String {
                return ledger + "Nonce: \(nonce)"
            }
            
            guard var blockHash = self?.createHash(key: key),
                  let proofOfWork = self?.proofOfWork else {
                return
            }
            
            while(!blockHash.hasPrefix(proofOfWork)) {
                
                nonce += 1
                
                guard let hash = self?.createHash(key: key) else {
                    return
                }
                
                blockHash = hash
                
                if nonce % 5000 == 0 {
                    DispatchQueue.main.async { [weak self] in
                        self?.didUpdateProofOfWork?("\(blockHash.prefix(4))\n")
                    }
                }
            }
            
            let block = Block(index: index,
                              hash: blockHash,
                              previousHash: previousHash,
                              transaction: transaction,
                              reward: reward,
                              key: key,
                              nonce: nonce)
            
            self?.blockchain.blocks.append(block)
            
            DispatchQueue.main.async { [weak self] in
                self?.didUpdateProofOfWork?("\(blockHash.prefix(4))\n(\(nonce) itera????es)")
                self?.didFinishMining?(block)
            }
        }
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
        
        let message = "\(sender.name) transferiu L$ \(String(format: "%.2f", amount)) para \(receiver.name) em \(Timestamp.string())"
        
        guard let publicKey = sender.publicKey,
              let signature = sign(message: message,
                                   privateKey: privateKey,
                                   publicKey: publicKey) else {
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
        
        ledger += "Hash do bloco anterior: \(previousHash)\n"
        ledger += "Recompensa por minera????o: \(rewardMessage)\n"
        ledger += "Transa????o: \(transactionMessage)\n"
        
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
    
    /// Performs computational work to mine the genesis block.
    ///
    /// This method mines the genesis block by iterating a nonce util the hash of the block's key (composed by index,
    /// message and nonce) has 4 zeros as the first 4 characters. During the hash processing, the `didUpdateProofOfWork`
    /// closure is called when the nonce is divisible by 5000. Due to this hash processing, is recommended to call this method in
    /// the background thread. When the mining computational work is done, the resulting genesis block is added to the blockchain
    /// and the `didCreateBlockchain` and `didUpdateProofOfWork` closures are called in the main thread, passing
    /// the mined `Block` as parameter.
    ///
    /// - Parameter miner: Peer that will mine the genesis block.
    private func mineGenesisBlock(miner: Peer) {
        
        let ledger = "??ndice: 0\nMensagem: Bloco G??nesis, criado por \(miner.name) em \(Timestamp.string())\n"
        
        var nonce = 0
        
        var key: String {
            return ledger + "Nonce: \(nonce)"
        }
        
        var blockHash = createHash(key: key)
        
        while(!blockHash.hasPrefix(proofOfWork)) {
            
            nonce += 1
            blockHash = createHash(key: key)
            
            if nonce % 5000 == 0 {
                DispatchQueue.main.async { [weak self] in
                    self?.didUpdateProofOfWork?("\(blockHash.prefix(4))\n")
                }
            }
        }
        
        let genesisBlock = Block(index: 0,
                                 hash: blockHash,
                                 previousHash: nil,
                                 transaction: nil,
                                 reward: nil,
                                 key: key,
                                 nonce: nonce)
        
        blockchain.blocks.append(genesisBlock)
        
        let blockchain = self.blockchain
        
        DispatchQueue.main.async { [weak self] in
            self?.didUpdateProofOfWork?("\(blockHash.prefix(4))\n(\(nonce) itera????es)")
            self?.didCreateBlockchain?(blockchain)
        }
    }
}
