//
//  LobbyViewController.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 09/10/21.
//

import Foundation
import UIKit
import MultipeerConnectivity

enum SessionRole {
    case host
    case guest
}

final class LobbyViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let sessionRole: SessionRole
    
    private let sessionDelegate: BlockchainSessionDelegate = BlockchainSessionDelegate()
    
    private let broadcaster: BlockchainBroadcaster
    
    /// Multi-peer session that enables the blockchain peer-to-peer communication.
    private let mcSession: MCSession
    
    /// Identification of the peer in the multi-peer session. Is set as the `name` property of `Peer` model.
    private let peerID: MCPeerID
    
    /// User information modeled into the `Peer` struct, containing the user's name and public key.
    private let userPeer: Peer
    
    /// Object in charge of advertising that the user is available for joining a nearby session. Through its delegate
    /// (declared in *BlockchainSession.swift*) it handles invitations from other peers.
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    
    /// Object in charge of browsing for available nearby peers to join the user's session. Through its delegate
    /// (declared in *BlockchainSession.swift*) it handles discovered peers nearby.
    private let serviceBrowser: MCNearbyServiceBrowser
    
    /// View controlled by this class, responsible for the interface.
    private let containerView: LobbyView
    
    // MARK: - Initializers
    
    init(sessionRole: SessionRole, userPeer: Peer) {
        
        self.sessionRole = sessionRole
        self.userPeer = userPeer
        self.peerID = MCPeerID(displayName: userPeer.name)
        
        self.mcSession = MCSession(peer: peerID,
                                   securityIdentity: nil,
                                   encryptionPreference: .required)
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID,
                                                           discoveryInfo: nil,
                                                           serviceType: "cl-lo")
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerID,
                                                     serviceType: "cl-lo")
        
        self.containerView = LobbyView(sessionRole: sessionRole,
                                       mcSession: mcSession,
                                       userPeer: userPeer)
        
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
    
    /// Loads the view as the container view (of type `LobbyView`).
    override func loadView() {
        view = containerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Lobby"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Private methods
    
    private func setup() {
        
        bindViewEvents()
        
        serviceBrowser.delegate = self
        serviceAdvertiser.delegate = self
        mcSession.delegate = sessionDelegate
        sessionDelegate.lobbyDelegate = containerView
        
        if sessionRole == .host {
            serviceBrowser.startBrowsingForPeers()
        } else {
            serviceAdvertiser.startAdvertisingPeer()
        }
    }
    
    private func bindViewEvents() {
        
        containerView.didTapStart = { [weak self] in
            self?.startSession()
        }
    }
    
    private func acceptInvite() {
        serviceAdvertiser.stopAdvertisingPeer()
    }
    
    private func showInviteAlert(host: MCPeerID,
                                 invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        let alert = UIAlertController(title: "Convite de sessão",
                                      message: "Gostaria de ingressar na sessão de \(host.displayName)?",
                                      preferredStyle: .alert)
        
        let declineAction = UIAlertAction(title: "Rejeitar", style: .default) { _ in
            invitationHandler(false, nil)
        }
        
        let acceptAction = UIAlertAction(title: "Aceitar", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.acceptInvite()
            invitationHandler(true, self.mcSession)
        }
        
        alert.addAction(declineAction)
        alert.addAction(acceptAction)
        
        present(alert, animated: true)
    }
    
    private func startSession() {
        
        if sessionRole == .host {
            serviceBrowser.stopBrowsingForPeers()
            broadcaster.broadcast(information: .message("Start session"))
        }
        
        let controller = BlockchainViewController(sessionDelegate: sessionDelegate,
                                                  mcSession: mcSession,
                                                  broadcaster: broadcaster,
                                                  userPeer: userPeer,
                                                  sessionRole: sessionRole)
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
/// The `MCNearbyServiceAdvertiserDelegate` protocol is responsible for handling peer advertiser-related events.
/// Basically, it deals with scenarios where the pair is looking for a session to join. The main scenario covered
/// by this delegate is when invite to join a session arrives from another nearby peer.
extension LobbyViewController: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        showInviteAlert(host: peerID, invitationHandler: invitationHandler)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
/// The `MCNearbyServiceBrowserDelegate` protocol is responsible for handling peer browser-related events.
/// Basically, it deals with scenarios where the pair is looking for a peers to invite to a session. The two main scenarios covered
/// by this delegate are:
/// 1. A new peer is discovered nearby and should be invited to join the session.
/// 2. A nearby peer identified by the browser is lost.
extension LobbyViewController: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String: String]?) {
        
        print("ServiceBrowser found peer: \(peerID)")
        browser.invitePeer(peerID, to: mcSession, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser,
                 lostPeer peerID: MCPeerID) {
        
        print("ServiceBrowser lost peer: \(peerID)")
    }
}
