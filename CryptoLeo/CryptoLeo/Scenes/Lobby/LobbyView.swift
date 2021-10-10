//
//  LobbyView.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 09/10/21.
//

import Foundation
import UIKit
import MultipeerConnectivity

/// Object responsible for multi-peer session lobby interface.
final class LobbyView: UIView {
    
    // MARK: - Internal properties
    
    /// Closure called when start button is tapped or when `startSession` method is called.
    var didStartSession: (() -> Void)?
    
    // MARK: - Private properties
    
    /// Role that the user is playing in the current session.
    private let sessionRole: SessionRole
    
    /// User information modeled into `Peer` struct, containing the user's name and public key.
    private let userPeer: Peer
    
    /// Multi-peer session that enables the blockchain peer-to-peer communication.
    private let mcSession: MCSession
    
    /// Button thats calls `didTapStart` closure when touched in.
    private let startButton: UIButton = {
        let button = UIButton()
        button.setTitle("Começar", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        return button
    }()
    
    /// Table view with connected peers data.
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    // MARK: - Initializers
    
    /// Initializes a `LobbyView`.
    ///
    /// - Parameter sessionRole: Role that the user is playing in the current session.
    /// - Parameter mcSession: Multi-peer session that enables the blockchain peer-to-peer communication.
    /// - Parameter userPeer: User information modeled into `Peer` struct.
    init(sessionRole: SessionRole, mcSession: MCSession, userPeer: Peer) {
        self.sessionRole = sessionRole
        self.mcSession = mcSession
        self.userPeer = userPeer
        super.init(frame: .zero)
        setup()
    }
    
    /// Unavailable required initializer.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    /// Setup the view by building its hierarchy, adding constraints to its subviews,
    /// adding action and hiding the start button, and setting the background color.
    private func setup() {
        
        buildView()
        addConstraints()
        
        startButton.addTarget(self, action: #selector(startButtonHandler), for: .touchUpInside)
        startButton.isHidden = true
        
        backgroundColor = .tertiarySystemBackground
    }
    
    /// Add subviews to the view.
    private func buildView() {
        addSubview(tableView)
        addSubview(startButton)
    }
    
    /// Applies constraints to all subviews.
    private func addConstraints() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        if sessionRole == .host {
            
            NSLayoutConstraint.activate([
                tableView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -20),
                startButton.heightAnchor.constraint(equalToConstant: 40),
                startButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
                startButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
                startButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40)
            ])
            
        } else {
            
            NSLayoutConstraint.activate([
                tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }
    
    /// Configures the visibility of the start button according to the session role and the number of connected peers.
    private func configureStartButton() {
        if sessionRole == .host {
            startButton.isHidden = mcSession.connectedPeers.count < 1
        }
    }
    
    /// Calls `didTapStart` closure when button action is triggered.
    @objc
    private func startButtonHandler() {
        didStartSession?()
    }
}

// MARK: - UITableViewDataSource and UITableViewDelegate
/// The `UITableViewDataSource` protocol is responsible for managing the presentation of the table view data
/// and the `UITableViewDelegate` protocol is responsible fot managing table view's interface and actions.
extension LobbyView: UITableViewDataSource, UITableViewDelegate {
    
    /// Sets the number of rows in section as the connected peers in the local network session plus 2, representing
    /// the usr itself and the searching feedback cell.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mcSession.connectedPeers.count + 2
    }
    
    /// Configures the table view's cells. It creates `UITableViewCell` with `.default` style and customizes the interface
    /// according to the index path. If is the fist row, creates a cell with the user name. If is the last row, creates a cell with
    /// searching message. Else, creates cells with the connected peers names.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.contentView.backgroundColor = .tertiarySystemBackground
        cell.selectionStyle = .none
        
        if indexPath.row != mcSession.connectedPeers.count + 1 {
            
            let text = indexPath.row == 0 ?
            "\(userPeer.name) (Eu)" : mcSession.connectedPeers[indexPath.row-1].displayName
            
            cell.textLabel?.text = text
            cell.textLabel?.font = .preferredFont(forTextStyle: .title3)
            cell.imageView?.image = UIImage(systemName: "personalhotspot")
            cell.imageView?.tintColor = .label
            
        } else {
            
            cell.textLabel?.text = "Procurando..."
            cell.textLabel?.font = .preferredFont(forTextStyle: .subheadline)
            cell.textLabel?.textColor = .systemGray
            cell.textLabel?.textAlignment = .center
        }
        
        return cell
    }
    
    
    /// Configures the height of each cell. If is the last cell, the height is set to `24`, else it set to `56`.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return indexPath.row != mcSession.connectedPeers.count + 1 ? 56 : 24
    }
}

// MARK: - BlockchainDelegate
/// The `BlockchainDelegate` protocol is responsible for multi-peer session lobby related events,
/// such as receiving messages and peers states.
extension LobbyView: LobbyDelegate {
    
    /// Calls the `didTapStart` closure in the main thread.
    func startSession() {
        
        DispatchQueue.main.async { [weak self] in
            self?.didStartSession?()
        }
    }
    
    /// Reloads the table view data and  calls `configureStartButton` method, both in the main thread.
    func connectNewPeerToSession() {
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.configureStartButton()
        }
    }
}
