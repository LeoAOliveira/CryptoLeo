//
//  LobbyViewController.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 09/10/21.
//

import Foundation
import UIKit
import MultipeerConnectivity

/// Object responsible for controlling the multi-peer session lobby, both connectivity and interface. It communicates
/// with nearby peers in the local network by implementing `MCNearbyService` delegate protocols.
final class LobbyViewController: UIViewController {
    
    // MARK: - Private properties
    
    /// Role that the user is playing in the current session.
    private let sessionRole: SessionRole
    
    /// User information modeled into `Peer` struct, containing the user's name and public key.
    private let userPeer: Peer
    
    /// Identification of the peer in the multi-peer session. Is set as the `name` property of `Peer` model.
    private let peerID: MCPeerID
    
    /// Multi-peer session that enables the blockchain peer-to-peer communication.
    private let mcSession: MCSession
    
    /// Object in charge of advertising that the user is available for joining a nearby session.
    /// Through its delegate (declared in this class extension)  it handles invitations from other peers.
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    
    /// Object in charge of browsing for available nearby peers to join the user's session.
    /// Through its delegate (declared in this class extension) it handles discovered peers nearby.
    private let serviceBrowser: MCNearbyServiceBrowser
    
    /// Object that conforms with `MCSessionDelegate`. It's responsible for handling session-related events,
    /// such as connected peers in the local network session and received data.
    private let sessionDelegate = BlockchainSessionDelegate()
    
    /// Object responsible to broadcast blockchain-related events to all connected peers in the local network.
    private let broadcaster: BlockchainBroadcaster
    
    /// View controlled by this class, responsible for the interface.
    private let containerView: LobbyView
    
    // MARK: - Initializers
    
    /// Initializes a `LobbyViewController`.
    ///
    /// Initializes the object and the following properties:
    /// - `peerID`: Identification of the peer in the multi-peer session.
    /// -  `mcSession`: Multi-peer session that enables the blockchain peer-to-peer communication.
    /// - `serviceAdvertiser`: Object in charge of advertising that the user is available for joining a nearby session.
    /// -  `serviceBrowser`: Object in charge of browsing for available nearby peers to join the user's session.
    /// -  `broadcaster`: Object responsible to broadcast blockchain-related events to all connected peers.
    /// - `containerView`: View controlled by this class, responsible for the interface.
    ///
    /// - Parameter sessionRole: Role that the user is playing in the current session.
    /// - Parameter userPeer: User information modeled into `Peer` struct.
    init(sessionRole: SessionRole, userPeer: Peer) {
        
        self.sessionRole = sessionRole
        self.userPeer = userPeer
        self.peerID = MCPeerID(displayName: userPeer.name)
        
        self.mcSession = MCSession(peer: peerID,
                                   securityIdentity: nil,
                                   encryptionPreference: .required)
        
        /// "cl-lo" stands for "CryptoLeo-LeonardoOliveira"
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID,
                                                           discoveryInfo: nil,
                                                           serviceType: "cl-lo")
        
        /// "cl-lo" stands for "CryptoLeo-LeonardoOliveira"
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerID,
                                                     serviceType: "cl-lo")
        
        self.broadcaster = BlockchainBroadcaster(mcSession: mcSession)
        
        self.containerView = LobbyView(sessionRole: sessionRole,
                                       mcSession: mcSession,
                                       userPeer: userPeer)
        
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
    
    /// Configures the navigation bar when the view is loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Lobby"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Private methods
    
    /// Setup the object by binding the container view events, attributing multi-peer related objects delegates, and
    /// starts browsing (when user is the session host) or advertising (when user is a guest in session) for nearby peers.
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
    
    /// Binds all container view events.
    private func bindViewEvents() {
        
        containerView.didStartSession = { [weak self] in
            self?.startSession()
        }
    }
    
    /// Presents an alert with an invitation to join a nearby session.
    ///
    /// Creates an `UIAlertController` with 2 actions:
    /// - Accept: stops advertising peers nearby and calls `invitationHandler` with `true` and the current session.
    /// - Decline: calls `invitationHandler` with `false`.
    ///
    /// - Parameter host: The `MCPeerID` of the session host.
    /// - Parameter invitationHandler: Response to the invitation.
    private func presentInviteAlert(host: MCPeerID,
                                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        let alert = UIAlertController(title: "Convite de sessão",
                                      message: "Gostaria de ingressar na sessão de \(host.displayName)?",
                                      preferredStyle: .alert)
        
        let declineAction = UIAlertAction(title: "Rejeitar", style: .default) { _ in
            invitationHandler(false, nil)
        }
        
        let acceptAction = UIAlertAction(title: "Aceitar", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.serviceAdvertiser.stopAdvertisingPeer()
            invitationHandler(true, self.mcSession)
        }
        
        alert.addAction(declineAction)
        alert.addAction(acceptAction)
        
        present(alert, animated: true)
    }
    
    /// Starts the blockchain session.
    ///
    /// Navigates to `BlockchainViewController` and, if the user is the session host, it stops
    /// browsing for nearby peers and broadcast to the connected ones a "Start session" message.
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
        
        presentInviteAlert(host: peerID, invitationHandler: invitationHandler)
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
