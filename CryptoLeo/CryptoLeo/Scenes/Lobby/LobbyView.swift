//
//  LobbyView.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 09/10/21.
//

import Foundation
import UIKit
import MultipeerConnectivity

final class LobbyView: UIView {
    
    // MARK: - Internal properties
    
    var didTapStart: (() -> Void)?
    
    // MARK: - Private properties
    
    private let sessionRole: SessionRole
    
    /// Multi-peer session that enables the blockchain peer-to-peer communication.
    private let mcSession: MCSession
    
    /// User information modeled into the `Peer` struct, containing the user's name and public key.
    private let userPeer: Peer
    
    private let startButton: UIButton = {
        let button = UIButton()
        button.setTitle("Começar", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    // MARK: - Initializers
    
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
    
    private func setup() {
        buildView()
        addConstraints()
        addActions()
        backgroundColor = .tertiarySystemBackground
        startButton.isHidden = true
    }
    
    private func buildView() {
        addSubview(tableView)
        addSubview(startButton)
    }
    
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
    
    private func addActions() {
        startButton.addTarget(self, action: #selector(startButtonHandler), for: .touchUpInside)
    }
    
    private func configureStartButton() {
        if sessionRole == .host {
            startButton.isHidden = mcSession.connectedPeers.count < 1
        }
    }
    
    @objc
    private func startButtonHandler() {
        didTapStart?()
    }
}

extension LobbyView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mcSession.connectedPeers.count + 2
    }
    
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return indexPath.row != mcSession.connectedPeers.count + 1 ? 56 : 24
    }
}

extension LobbyView: LobbyDelegate {
    
    func startSession() {
        DispatchQueue.main.async { [weak self] in
            self?.didTapStart?()
        }
    }
    
    func connectNewPeerToSession() {
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.configureStartButton()
        }
    }
}
