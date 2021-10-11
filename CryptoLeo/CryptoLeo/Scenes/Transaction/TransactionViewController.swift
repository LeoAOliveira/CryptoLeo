//
//  TransactionViewController.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 10/10/21.
//

import Foundation
import UIKit
import MultipeerConnectivity

/// Object responsible for controlling the transaction screen, both logic and interface.
final class TransactionViewController: UIViewController {
    
    // MARK: - Internal properties
    
    /// Closure called a transfer is sent.
    var didSendTransfer: ((MCPeerID, Double) -> Void)?
    
    // MARK: - Private properties
    
    /// Multi-peer session that enables the blockchain peer-to-peer communication.
    private let mcSession: MCSession
    
    /// Object responsible to broadcast blockchain-related events to all connected peers in the local network.
    private let broadcaster: BlockchainBroadcaster
    
    /// Object responsible for intermediating blockchain operations.
    private let transactor: BlockchainTransactor
    
    /// User information modeled into `Peer` struct, containing the user's name and public key.
    private let userPeer: Peer
    
    /// View controlled by this class, responsible for the interface.
    private let containerView: TransactionView
    
    // MARK: - Initializers
    
    /// Initializes a `TransactionViewController` and a `TransactionView`.
    ///
    /// - Parameter mcSession: Multi-peer session that enables the blockchain peer-to-peer communication.
    /// - Parameter broadcaster: Object responsible to broadcast blockchain-related events to all connected peers.
    /// - Parameter transactor: Object responsible for intermediating blockchain operations.
    /// - Parameter userPeer: User information modeled into `Peer` struct.
    init(mcSession: MCSession,
         broadcaster: BlockchainBroadcaster,
         transactor: BlockchainTransactor,
         userPeer: Peer,
         cryptoLeoAmount: Double) {
        
        self.mcSession = mcSession
        self.userPeer = userPeer
        self.transactor = transactor
        self.broadcaster = broadcaster
        self.containerView = TransactionView(peers: mcSession.connectedPeers,
                                             cryptoLeoAmount: cryptoLeoAmount)
        
        super.init(nibName: nil, bundle: nil)
        
        bindViewEvents()
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
    
    /// Bind all events from `containerView`.
    private func bindViewEvents() {
        
        containerView.didTapTransfer = { [weak self] receiver, amount in
            self?.dismiss(animated: true, completion: { [weak self] in
                self?.didSendTransfer?(receiver, amount)
            })
        }
        
        containerView.didSurpassLimit = { [weak self] in
            let alert = AlertFactory.createDefaultAlert(title: "Transação negada",
                                                        description: "Valor de CryptoLeo acima do saldo.")
            self?.present(alert, animated: true)
        }
    }
}
