//
//  BlockchainViewController.swift
//  Crypto Leo
//
//  Created by Leonardo Oliveira on 27/09/21.
//

import Foundation
import UIKit
import MultipeerConnectivity

/// Object responsible for controlling the multi-peer blockchain session, both connectivity and interface. It communicates
/// with nearby peers in the local network by through a given `BlockchainSessionDelegate` and process the received
/// information through the implemented `BlockchainDelegate` protocol.
final class BlockchainViewController: UIViewController {
    
    // MARK: - Private properties
    
    /// Object that conforms with `MCSessionDelegate`. It's responsible for handling session-related events,
    /// such as connected peers in the local network session and received data.
    private let sessionDelegate: BlockchainSessionDelegate
    
    /// Multi-peer session that enables the blockchain peer-to-peer communication.
    private let mcSession: MCSession
    
    /// Object responsible to broadcast blockchain-related events to all connected peers in the local network.
    private let broadcaster: BlockchainBroadcaster
    
    /// User information modeled into `Peer` struct, containing the user's name and public key.
    private let userPeer: Peer
    
    /// Reference to `BlockchainTransactor`, responsible for intermediating blockchain operations.
    private let transactor: BlockchainTransactor
    
    /// Role that the user is playing in the current session.
    private let sessionRole: SessionRole
    
    /// View controlled by this class, responsible for the interface.
    private let containerView = BlockchainView()
    
    // MARK: - Initializers
    
    /// Initializes a `BlockchainViewController` and a `BlockchainTransactor`,
    /// responsible for intermediating blockchain operations.
    ///
    /// - Parameter blockchainName: Name for the blockchain.
    /// - Parameter creator: User information modeled into the `Peer` struct.
    init(sessionDelegate: BlockchainSessionDelegate,
         mcSession: MCSession,
         broadcaster: BlockchainBroadcaster,
         userPeer: Peer,
         sessionRole: SessionRole) {
        
        self.sessionDelegate = sessionDelegate
        self.mcSession = mcSession
        self.userPeer = userPeer
        self.sessionRole = sessionRole
        self.transactor = BlockchainTransactor(sessionRole: sessionRole, userPeer: userPeer)
        self.broadcaster = broadcaster
        
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
    
    /// When the view is loaded, configures the navigation bar and
    /// presents a `LoadingView` while host is mining the genesis block.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Blockchain"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.setHidesBackButton(true, animated: true)
        
        setGenesisBlockLoading(isHidden: false)
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
    /// - Updates on proof-of-work process.
    private func bindBlockchainEvents() {
        
        /// When blockchain creation is completed, it broadcasts the genesis block to
        /// connected peers and hides the `LoadingView`.
        transactor.didCreateBlockchain = { [weak self] block in
            self?.broadcaster.broadcast(information: .newBlock(block))
            self?.setGenesisBlockLoading(isHidden: true)
            print("Blockchain created and genesis block mined")
        }
        
        transactor.didUpdateBlockchain = { blockchain in
            print("Blockchain updated to \(blockchain.blocks.count) blocks")
        }
        
        /// When a transaction is created, it broadcasts the transaction to connected peers.
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
        
        /// When a proof-of-work process is updated, it updated the proof-of-work label at `LoadingView`.
        transactor.didUpdateProofOfWork = { [weak self] message in
            self?.containerView.updateLoadingProofOfWork(message: message)
        }
    }
    
    private func setGenesisBlockLoading(isHidden: Bool) {
        containerView.setGenesisBlockLoading(isHidden: isHidden,
                                             sessionRole: sessionRole)
    }
}

// MARK: - BlockchainDelegate
/// The `BlockchainDelegate` protocol is responsible for blockchain session related events, such as receiving models.
extension BlockchainViewController: BlockchainDelegate {
    
    /// Updates the stored blockchain with a received one (send by a connected peer) by
    /// calling `updateBlockchain` method from `BlockchainTransactor`.
    /// - Parameter blockchain: The updated blockchain received from a peer.
    func updateBlockchain(with blockchain: Blockchain) {
        transactor.updateBlockchain(with: blockchain)
    }
    
    /// Adds a new block to the blockchain by calling `addBlockToBlockchain` method from `BlockchainTransactor`.
    /// Also, calls the container view's `setGenesisBlockLoading` in the main thread to hide the `LoadingView`.
    func addBlockToBlockchain(block: Block) {
        do {
            try transactor.addBlockToBlockchain(block: block)
        } catch {
            print(error.localizedDescription)
        }
        
        if block.previousHash == nil {
            DispatchQueue.main.async { [weak self] in
                self?.setGenesisBlockLoading(isHidden: true)
            }
        }
    }
    
    /// Mines a received block from a connected peer by calling `mineBlock` method from `BlockchainTransactor`.
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
