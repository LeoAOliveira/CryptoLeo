//
//  BlockchainViewController.swift
//  Crypto Leo
//
//  Created by Leonardo Oliveira on 27/09/21.
//

import UIKit
import CryptoKit
import MultipeerConnectivity

final class BlockchainViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let userPeer: Peer
    private let blockchainName: String
    
    private(set) lazy var transactor = Transactor(blockchainName: blockchainName, userPeer: userPeer)
    
    private lazy var blockchainSession: BlockchainSession = {
        let session = BlockchainSession(mcSession: mcSession)
        session.controller = self
        return session
    }()
    
    private lazy var peerID = MCPeerID(displayName: UIDevice.current.name)
    
    private lazy var mcSession = MCSession(peer: peerID,
                                           securityIdentity: nil,
                                           encryptionPreference: .required)
    
    private lazy var mcAssistant = MCAdvertiserAssistant(serviceType: "cl-lo",
                                                         discoveryInfo: nil,
                                                         session: mcSession)
    
    // MARK: - Initializers
    
    init(blockchainName: String, userPeer: Peer) {
        self.userPeer = userPeer
        self.blockchainName = blockchainName
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mcAssistant.start()
        bindBlockchainEvents()
    }
}

// MARK: - Blockchain's transactor methods

extension BlockchainViewController {
    
    func bindBlockchainEvents() {
        
        transactor.didCreateBlockchain = { blockchain in
            print("\(blockchain.name) created")
        }
        
        transactor.didUpdateBlockchain = { blockchain in
            print("Blockchain updated to \(blockchain.blocks.count) blocks")
        }
        
        transactor.didTransferCrypto = { [weak self] transaction in
            self?.blockchainSession.broadcast(information: .newTransaction(transaction))
            print(transaction.message)
        }
        
        transactor.didAddNewBlock = { block in
            print("Add new block: \(block.key)")
        }
        
        transactor.didFinishMining = { block in
            print("Finished mining: \(block.hash)")
        }
    }
    
    func updateBlockchain(with blockchain: Blockchain) {
        transactor.updateBlockchain(with: blockchain)
    }
    
    func addBlockToBlockchain(block: Block) {
        
        do {
            try transactor.addBlockToBlockchain(block: block)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func mineBlock(transaction: Transaction) {
        transactor.mineBlock(transaction: transaction)
    }
    
    func getCurrentBlockchain() -> Blockchain {
        return transactor.blockchain
    }
}
