//
//  BlockchainViewController.swift
//  Crypto Leo
//
//  Created by Leonardo Oliveira on 27/09/21.
//

import Foundation
import UIKit
import CryptoKit
import MultipeerConnectivity

final class BlockchainViewController: UIViewController {
    
    // MARK: - Internal properties
    
    /// Multi-peer session that enables the blockchain peer-to-peer communication.
    let mcSession: MCSession
    
    // MARK: - Private properties
    
    /// Name given to the blockchain.
    private let blockchainName: String
    
    /// User information modeled into the `Peer` struct, containing the user's name and public key.
    private let userPeer: Peer
    
    /// Reference to `Transactor`, responsible for intermediating blockchain operations.
    private let transactor: Transactor
    
    /// Identification of the peer in the multi-peer session. Is set as the `name` property of `Peer` model.
    private let peerID: MCPeerID
    
    /// Object in charge of advertising that the user is available for joining a nearby session. Through its delegate
    /// (declared in *BlockchainSession.swift*) it handles invitations from other peers.
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    
    /// Object in charge of browsing for available nearby peers to join the user's session. Through its delegate
    /// (declared in *BlockchainSession.swift*) it handles discovered peers nearby.
    private let serviceBrowser: MCNearbyServiceBrowser
    
    /// View controlled by this class, responsible for the interface.
    private let containerView = BlockchainView()
    
    // MARK: - Initializers
    
    /// Initializes a `BlockchainViewController`.
    /// - Parameter blockchainName: Name for the blockchain.
    /// - Parameter creator: User information modeled into the `Peer` struct.
    init(blockchainName: String, userPeer: Peer) {
        
        self.userPeer = userPeer
        self.blockchainName = blockchainName
        
        self.transactor = Transactor(blockchainName: blockchainName,
                                     userPeer: userPeer)
        
        self.peerID = MCPeerID(displayName: userPeer.name)
        
        self.mcSession = MCSession(peer: peerID,
                                 securityIdentity: nil,
                                 encryptionPreference: .required)
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID,
                                                           discoveryInfo: nil,
                                                           serviceType: "cl-lo")
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerID,
                                                     serviceType: "cl-lo")
        
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    /// Unavailable required initializer.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle methods
    
    /// Loads the view as the container view (of type `BlockchainView`).
    override func loadView() {
        view = containerView
    }
    
    // MARK: - Private methods
    
    /// Setups the class by setting up multi-peer delegates and binding view and blockchain events.
    private func setup() {
        setupDelegates()
        bindBlockchainEvents()
        bindViewEvents()
    }
    
    /// Setups all multi-peer related delegates, such as:
    /// - `MCSessionDelegate`
    /// - `MCNearbyServiceAdvertiserDelegate`
    /// - `MCNearbyServiceBrowserDelegate`
    private func setupDelegates() {
        mcSession.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
    }
    
    /// Bind all events from `containerView`.
    private func bindViewEvents() {
        containerView.didTapTransfer = { [weak self] in
            print("clicked")
            self?.serviceAdvertiser.startAdvertisingPeer()
            self?.serviceBrowser.startBrowsingForPeers()
        }
    }
}

// MARK: - Blockchain's transactor methods

extension BlockchainViewController {
    
    /// Bind all events from blockchain`Transactor`:
    /// - When blockchain creation is completed;
    /// - When block chain is updated;
    /// - When a transaction is created;
    /// - When a new block is added to the blockchain;
    /// - When finishes mining a block.
    func bindBlockchainEvents() {
        
        transactor.didCreateBlockchain = { blockchain in
            print("\(blockchain.name) created")
        }
        
        transactor.didUpdateBlockchain = { blockchain in
            print("Blockchain updated to \(blockchain.blocks.count) blocks")
        }
        
        transactor.didTransferCrypto = { [weak self] transaction in
            self?.broadcast(information: .newTransaction(transaction))
            print(transaction.message)
        }
        
        transactor.didAddNewBlock = { block in
            print("Add new block: \(block.key)")
        }
        
        transactor.didFinishMining = { block in
            print("Finished mining: \(block.hash)")
        }
    }
    
    /// Updates the stored blockchain with a received one (send by a connected peer) by
    /// calling `updateBlockchain` method from `Transactor`.
    /// - Parameter blockchain: The updated blockchain received from a peer.
    func updateBlockchain(with blockchain: Blockchain) {
        transactor.updateBlockchain(with: blockchain)
    }
    
    /// Adds a new block to the blockchain by calling `addBlockToBlockchain` method from `Transactor`.
    func addBlockToBlockchain(block: Block) {
        do {
            try transactor.addBlockToBlockchain(block: block)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Mines a received block from a connected peer by calling `mineBlock` method from `Transactor`.
    /// - Parameter transaction: A received transaction available for mining.
    func mineBlock(transaction: Transaction) {
        transactor.mineBlock(transaction: transaction)
    }
    
    /// Gets the current stored blockchain.
    /// - Returns: Current `Blockchain` model.
    func getCurrentBlockchain() -> Blockchain {
        return transactor.blockchain
    }
}
