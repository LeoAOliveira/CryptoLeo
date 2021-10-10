//
//  BlockchainSessionDelegate.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 06/10/21.
//

import Foundation
import MultipeerConnectivity

/// Object that conforms with `MCSessionDelegate` protocol, responsible for handling session-related events
/// of a `MCSession`.
///
/// Basically, it deals with two major scenarios from the blockchain peer-to-peer communication:
/// 1. Peers connected to the session, that represent blockchain peers and possible transactors and miners.
/// 2. Receiving information from other peers, such as the current blockchain, a new transaction to be mined or a new
///   mined block to be added to the blockchain.
final class BlockchainSessionDelegate: NSObject, MCSessionDelegate {
    
    // MARK: - Internal properties
    
    /// Delegate responsible for blockchain session related events, such as receiving models.
    weak var blockchainDelegate: BlockchainDelegate?
    
    /// Delegate responsible for multi-peer session lobby related events, such as receiving messages and peers states.
    weak var lobbyDelegate: LobbyDelegate?
    
    // MARK: - Internal methods
    
    /// Listen to nearby peers state changes..
    ///
    /// This method receives the nearby connected peers state in the session, such as connected, connecting and not
    /// connected. If the state is connected, the `LobbyDelegate.connectNewPeerToSession` function is called.
    ///
    /// - Parameter session: The session that the peer is connected in.
    /// - Parameter peerID: Identifier of the peer whose state is being analyzed.
    /// - Parameter state: Peer's connection state.
    func session(_ session: MCSession,
                 peer peerID: MCPeerID,
                 didChange state: MCSessionState) {
        
        print("peer \(peerID) didChangeState: \(state.rawValue)")

        switch state {

        case MCSessionState.connected:
            lobbyDelegate?.connectNewPeerToSession()
            print("Connected: \(peerID.displayName)")

        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")

        case MCSessionState.notConnected:
            lobbyDelegate?.connectNewPeerToSession()
            print("Not Connected: \(peerID.displayName)")

        @unknown default:
            print("Unknown")
        }
    }
    
    /// Receives and decode an information sent from another peer.
    ///
    /// This method receives and tries to decode an information sent by another peer with `JSONDecoder`
    /// using `Blockchain`, `Block` and `Transaction` models. Depending of the decoded information,
    /// a delegate function is called to continue the data treatment.
    ///
    /// - Parameter session: The session that the peer is connected in.
    /// - Parameter data: The received information.
    /// - Parameter fromPeer: Peer that sent the data.
    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {
        
        if let startSessionString = String(data: data, encoding: .utf8),
           startSessionString.contains("Start session") {
            lobbyDelegate?.startSession()
            
        } else if let blockchain = try? JSONDecoder().decode(Blockchain.self, from: data) {
            blockchainDelegate?.updateBlockchain(with: blockchain)
            
        } else if let block = try? JSONDecoder().decode(Block.self, from: data) {
            blockchainDelegate?.addBlockToBlockchain(block: block)
            
        } else if let transaction = try? JSONDecoder().decode(Transaction.self, from: data) {
            blockchainDelegate?.mineBlock(transaction: transaction)
        }
    }
    
    /// Unused (but required) `MCSessionDelegate` methods.
    
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
