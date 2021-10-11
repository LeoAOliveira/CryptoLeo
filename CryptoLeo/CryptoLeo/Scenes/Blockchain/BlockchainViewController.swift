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
    
    /// Object responsible for intermediating blockchain operations.
    private let transactor: BlockchainTransactor
    
    /// Role that the user is playing in the current session.
    private let sessionRole: SessionRole
    
    /// View controlled by this class, responsible for the interface.
    private let containerView = BlockchainView()
    
    /// Boolean describing if the user is set to mine blocks.
    private var mineBlocks = true
    
    // MARK: - Initializers
    
    /// Initializes a `BlockchainViewController` and a `BlockchainTransactor`,
    /// responsible for intermediating blockchain operations.
    ///
    /// - Parameter sessionDelegate: Object that conforms with `MCSessionDelegate`.
    /// - Parameter mcSession: Multi-peer session that enables the blockchain peer-to-peer communication.
    /// - Parameter broadcaster: Object responsible to broadcast blockchain-related events.
    /// - Parameter userPeer: User information modeled into `Peer` struct.
    /// - Parameter sessionRole: Role that the user is playing in the current session.
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
        
        /// When transfer button is tapped in the container view, the `presentTransactionViewController`
        /// method is called to perform the navigation.
        containerView.didTapTransfer = { [weak self] in
            self?.presentTransactionViewController()
        }
        
        /// When the switch value is changed in the container view, the `mineBlocks`
        /// property is set to the received `isOn`value.
        containerView.didChangeSwitch = { [weak self] isOn in
            self?.mineBlocks = isOn
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
        transactor.didCreateBlockchain = { [weak self] blockchain in
            self?.broadcaster.broadcast(information: .updatedBlockchain(blockchain))
            self?.setGenesisBlockLoading(isHidden: true)
            self?.containerView.updateSessionInfo(sessionInfo: .blockchain)
            print("Blockchain created and genesis block mined")
        }
        
        transactor.didUpdateBlockchain = { [weak self] blockchain in
            self?.containerView.updateSessionInfo(sessionInfo: .blockchain)
            print("Blockchain updated to \(blockchain.blocks.count) blocks")
        }
        
        transactor.didAddNewBlock = { [weak self] block in
            self?.containerView.updateSessionInfo(sessionInfo: .blockchain)
            print("Add new block: \(block.key)")
        }
        
        /// When finishes mining a block, the `setMiningBlockLoading` method is called with
        /// `true` as parameter in order to hide the `LoadingView`.
        transactor.didFinishMining = { [weak self] block in
            self?.containerView.updateSessionInfo(sessionInfo: .blockchain)
            self?.containerView.updateSessionInfo(sessionInfo: .minedBlocks)
            self?.containerView.setMiningBlockLoading(isHidden: true)
            print("Finished mining: \(block.hash)")
        }
        
        /// When a proof-of-work process is updated, it updated the proof-of-work label at `LoadingView` by calling
        /// `updateLoadingProofOfWork` method with the given `message` as parameter.
        transactor.didUpdateProofOfWork = { [weak self] message in
            self?.containerView.updateLoadingProofOfWork(message: message)
        }
    }
    
    /// Sets the genesis block loading visibility.
    ///
    /// Calls the container view's `setGenesisBlockLoading` with the visibility `isHidden` and the user role
    /// in the multi-peer session `sessionRole`.
    ///
    /// - Parameter isHidden: Loading's visibility.
    private func setGenesisBlockLoading(isHidden: Bool) {
        containerView.setGenesisBlockLoading(isHidden: isHidden, sessionRole: sessionRole)
    }
    
    /// Creates and processes a transaction by either mining a block for it or broadcasting it to other nearby peers to mine.
    ///
    /// First, a `Peer` model is created. Then, is attempted to create a `Transaction` model, by calling the transactor's `createTransaction` method with the `Peer` model and the given amount as parameters. If it throws an error,
    /// an alert is presented. Created a `Transaction` model, the method verifies if the user is set to mine blocks through the
    /// `mineBlocks` private property. If is `true`, a mining alert is presented and, on its completion, it is called the container's
    /// view `setMiningBlockLoading` method (in order to present the `LoadingView`) and the transactor's `mineBlock`
    /// method (in order to start mining a block for the transaction). Else, a broadcast alert is presented and the broadcaster's
    /// `broadcast` method is called, passing the given `Transaction` model as parameter.
    ///
    /// - Parameter receiver: The connected peer that will receive the transaction.
    /// - Parameter amount: The amount that will be transferred.
    private func sendTransaction(receiver: MCPeerID, amount: Double) {
        
        let receiverPeer = Peer(name: receiver.displayName, publicKey: nil)
        
        guard let transaction = try? transactor.createTransaction(amount: amount,
                                                                  receiver: receiverPeer) else {
            presentDefaultAlert(title: "Erro na transação",
                                description: "Não foi possível assinar a transação com a sua assinatura digital. Tente novamente.")
            return
        }
        
        containerView.updateSessionInfo(sessionInfo: .transactionsSent)
        
        if mineBlocks {
            
            let description = "Para registrar a sua transferência, deve-se criar e minerar um bloco. Ao final, o bloco será inserido no blockchain."
            
            presentDefaultAlert(title: "Minerar bloco", description: description) { [weak self] in
                self?.containerView.setMiningBlockLoading(isHidden: false)
                self?.transactor.mineBlock(transaction: transaction)
            }
        
        } else {
            
            let description = "Sua transação foi enviada e será processada em breve."
            presentDefaultAlert(title: "Minerar bloco", description: description)
            broadcaster.broadcast(information: .newTransaction(transaction))
        }
    }
    
    /// Presents a default alert with the given information (created by the `AlertFactory`).
    ///
    /// - Parameter title: Alert's title.
    /// - Parameter description: Alert's description.
    /// - Parameter completion: Alert's completion closure, that will be executed when the user dismisses the alert.
    private func presentDefaultAlert(title: String,
                                     description: String,
                                     completion: (() -> Void)? = nil) {
        
        let alert = AlertFactory.createDefaultAlert(title: title,
                                                    description: description,
                                                    completion: completion)
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Navigation
/// Extension gathering all navigation-related methods.
extension BlockchainViewController {
    
    /// Creates a `TransactionViewController`, bind its events closures and presents it.
    private func presentTransactionViewController() {
        
        let controller = TransactionViewController(mcSession: mcSession,
                                                   broadcaster: broadcaster,
                                                   transactor: transactor,
                                                   userPeer: userPeer)
        
        controller.didSendTransfer = { [weak self] receiver, amount in
            self?.sendTransaction(receiver: receiver, amount: amount)
        }
        
        present(controller, animated: true)
    }
}


// MARK: - BlockchainDelegate
/// The `BlockchainDelegate` protocol is responsible for blockchain session related events, such as receiving models.
extension BlockchainViewController: BlockchainDelegate {
    
    /// Updates the stored blockchain with a received one (send by a connected peer) by calling `updateBlockchain`
    /// method from `BlockchainTransactor`. Also, calls the container view's `setGenesisBlockLoading` in
    /// the main thread to hide the `LoadingView`.
    /// - Parameter blockchain: The updated blockchain received from a peer.
    func updateBlockchain(with blockchain: Blockchain) {
        
        transactor.updateBlockchain(with: blockchain)
        
        DispatchQueue.main.async { [weak self] in
            self?.setGenesisBlockLoading(isHidden: true)
        }
    }
    
    /// Adds a new block to the blockchain by calling `addBlockToBlockchain` method from `BlockchainTransactor`.
    func addBlockToBlockchain(block: Block) {
        do {
            try transactor.addBlockToBlockchain(block: block)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Presents a default alert informing that a block is available for mining and, in its completion, mines
    /// the received block by calling `mineBlock` method from `BlockchainTransactor`.
    /// - Parameter transaction: A received transaction available for mining.
    func mineBlock(transaction: Transaction) {
        
        let description = "Você recebeu uma transação e deve criar e minerar um bloco. Ao final, o bloco será inserido no blockchain."
        
        presentDefaultAlert(title: "Minerar bloco", description: description) { [weak self] in
            self?.containerView.setMiningBlockLoading(isHidden: false)
            self?.transactor.mineBlock(transaction: transaction)
        }
    }
    
    /// Gets the current stored blockchain.
    /// - Returns: Current `Blockchain` model.
    func getCurrentBlockchain() -> Blockchain {
        return transactor.blockchain
    }
}
