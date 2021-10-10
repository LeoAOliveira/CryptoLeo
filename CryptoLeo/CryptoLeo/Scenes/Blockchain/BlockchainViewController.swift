//
//  BlockchainViewController.swift
//  Crypto Leo
//
//  Created by Leonardo Oliveira on 27/09/21.
//

import Foundation
import UIKit
import MultipeerConnectivity

final class BlockchainViewController: UIViewController {
    
    // MARK: - Private properties
    
    /// Multi-peer session that enables the blockchain peer-to-peer communication.
    private let mcSession: MCSession
    
    private let sessionDelegate: BlockchainSessionDelegate
    
    private let broadcaster: BlockchainBroadcaster
    
    /// User information modeled into the `Peer` struct, containing the user's name and public key.
    private let userPeer: Peer
    
    /// Reference to `Transactor`, responsible for intermediating blockchain operations.
    private let transactor: BlockchainTransactor
    
    /// View controlled by this class, responsible for the interface.
    private let containerView = BlockchainView()
    
    // MARK: - Initializers
    
    /// Initializes a `BlockchainViewController`.
    /// - Parameter blockchainName: Name for the blockchain.
    /// - Parameter creator: User information modeled into the `Peer` struct.
    init(sessionDelegate: BlockchainSessionDelegate, mcSession: MCSession, userPeer: Peer) {
        
        self.sessionDelegate = sessionDelegate
        self.mcSession = mcSession
        self.userPeer = userPeer
        self.transactor = BlockchainTransactor(blockchainName: "Blockchain", userPeer: userPeer)
        self.broadcaster = BlockchainBroadcaster(mcSession: mcSession)
        
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
        bindBlockchainEvents()
        bindViewEvents()
        sessionDelegate.blockchainDelegate = self
    }
    
    /// Bind all events from `containerView`.
    private func bindViewEvents() {
        containerView.didTapTransfer = {
            print("clicked")
        }
    }
    
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
            self?.broadcaster.broadcast(information: .newTransaction(transaction))
            print(transaction.message)
        }
        
        transactor.didAddNewBlock = { block in
            print("Add new block: \(block.key)")
        }
        
        transactor.didFinishMining = { block in
            print("Finished mining: \(block.hash)")
        }
    }
}

// MARK: - Blockchain's transactor methods

extension BlockchainViewController: BlockchainDelegate {
    
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

// MARK: - Navigation

extension BlockchainViewController {
    
//    private func presentLobby() {
//        
//        let controller = LobbyViewController(sessionRole: sessionRole,
//                                             mcSession: mcSession,
//                                             peerID: peerID)
//        
//        controller.isModalInPresentation = true
//        
//        present(controller, animated: true)
//    }
}
