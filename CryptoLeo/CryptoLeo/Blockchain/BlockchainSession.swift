//
//  BlockchainSession.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 06/10/21.
//

import Foundation
import CryptoKit
import MultipeerConnectivity

// MARK: - Blockchain multi-peer session methods
/// This extension is responsible for gathering all blockchain's multi-peer session-related methods, such as
/// information encode and decode, and data broadcast and reception.
extension BlockchainViewController {
    
    /// Broadcasts a given information to all peers connected to the current session.
    ///
    /// This method encodes the given `BroadcastInformation` to `Data` (with a `JSONEncoder`) and sends it
    /// to all connected peers.
    ///
    /// - Parameter information: A `BroadcastInformation`, that can be the current `Blockchain` model,
    /// a recently mined and added `Block` model or a recently created `Transaction`.
    func broadcast(information: BroadcastInformation) {
        
        var data: Data?
        
        switch information {
        
        case .currentBlockchain(let blockchain):
            data = try? JSONEncoder().encode(blockchain)
            
        case .newBlock(let block):
            data = try? JSONEncoder().encode(block)
            
        case .newTransaction(let transaction):
            data = try? JSONEncoder().encode(transaction)
        }
        
        guard let broadcastData = data else {
            return
        }
        
        sendDataToPeers(data: broadcastData)
    }
    
    /// Sends a given `Data` to all connected peers.
    ///
    /// This method tries to send the given information (in `Data` encoding) to all peers connected to the session with reliability.
    /// If the process fails, it calls the function recursively incrementing 1 to the `attempt` parameter. The method has 3 attempts
    /// to successfully send the information to other peers. Else, it gives up broadcasting it.
    ///
    /// - Parameter data: The information to be sent.
    /// - Parameter attempt: The attempt for sending the information. Default value is `1`.
    private func sendDataToPeers(data: Data, attempt: Int = 1) {
        
        if attempt > 3 {
            return
        }
        
        do {
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
            
        } catch {
            sendDataToPeers(data: data, attempt: attempt + 1)
        }
    }
    
    /// Decodes an information received from another peer.
    ///
    /// This method tries to decode a received information with `JSONDecoder` using `Blockchain`, `Block`
    /// and `Transaction` models. Depending of the decoded information, a function is called to continue the treatment.
    ///
    /// - Parameter data: The received information.
    private func decodeReceivedData(data: Data) {
        
        if let blockchain = try? JSONDecoder().decode(Blockchain.self, from: data) {
            updateBlockchain(with: blockchain)
        }
        
        if let block = try? JSONDecoder().decode(Block.self, from: data) {
            addBlockToBlockchain(block: block)
        }
        
        if let transaction = try? JSONDecoder().decode(Transaction.self, from: data) {
            mineBlock(transaction: transaction)
        }
    }
}

// MARK: - MCSessionDelegate
/// The `MCSessionDelegate` protocol is responsible for handling session-related events of a `MCSession` .
/// Basically, it deals with two major scenarios from the blockchain peer-to-peer communication:
/// 1. Peers connected to the session, that represent blockchain peers and possible transactors and miners.
/// 2. Receiving information from other peers, such as the current blockchain, a new transaction to be mined or a new
///   mined block to be added to the blockchain.
extension BlockchainViewController: MCSessionDelegate {
    
    func session(_ session: MCSession,
                 peer peerID: MCPeerID,
                 didChange state: MCSessionState) {
        
        print("peer \(peerID) didChangeState: \(state.rawValue)")

        switch state {

        case MCSessionState.connected:

            print("Connected: \(peerID.displayName)")

            broadcast(information: .currentBlockchain(getCurrentBlockchain()))

        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")

        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")

        @unknown default:
            print("Unknown")
        }
    }
    
    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {
        
        decodeReceivedData(data: data)
    }
    
    func session(_ session: MCSession,
                 didReceive stream: InputStream,
                 withName streamName: String,
                 fromPeer peerID: MCPeerID) { }
    
    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 with progress: Progress) { }
    
    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, at localURL: URL?,
                 withError error: Error?) { }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
/// The `MCNearbyServiceAdvertiserDelegate` protocol is responsible for handling peer advertiser-related events.
/// Basically, it deals with scenarios where the pair is looking for a session to join. The main scenario covered
/// by this delegate is when invite to join a session arrives from another nearby peer.
extension BlockchainViewController: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        print("didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, mcSession)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
/// The `MCNearbyServiceBrowserDelegate` protocol is responsible for handling peer browser-related events.
/// Basically, it deals with scenarios where the pair is looking for a peers to invite to a session. The two main scenarios covered
/// by this delegate are:
/// 1. A new peer is discovered nearby and should be invited to join the session.
/// 2. A nearby peer identified by the browser is lost.
extension BlockchainViewController: MCNearbyServiceBrowserDelegate {

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
