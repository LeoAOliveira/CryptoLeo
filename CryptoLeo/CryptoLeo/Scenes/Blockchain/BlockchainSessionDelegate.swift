//
//  BlockchainSessionDelegate.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 06/10/21.
//

import Foundation
import MultipeerConnectivity

/// The `MCSessionDelegate` protocol is responsible for handling session-related events of a `MCSession` .
/// Basically, it deals with two major scenarios from the blockchain peer-to-peer communication:
/// 1. Peers connected to the session, that represent blockchain peers and possible transactors and miners.
/// 2. Receiving information from other peers, such as the current blockchain, a new transaction to be mined or a new
///   mined block to be added to the blockchain.
final class BlockchainSessionDelegate: NSObject, MCSessionDelegate {
    
    // MARK: - Internal properties
    
    weak var blockchainDelegate: BlockchainDelegate?
    weak var lobbyDelegate: LobbyDelegate?
    
    // MARK: - Internal methods
    
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
    
    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {
        
        decodeReceivedData(data: data)
    }
    
    /// Decodes an information received from another peer.
    ///
    /// This method tries to decode a received information with `JSONDecoder` using `Blockchain`, `Block`
    /// and `Transaction` models. Depending of the decoded information, a function is called to continue the treatment.
    ///
    /// - Parameter data: The received information.
    private func decodeReceivedData(data: Data) {
        
        if let blockchain = try? JSONDecoder().decode(Blockchain.self, from: data) {
            blockchainDelegate?.updateBlockchain(with: blockchain)
        }
        
        if let block = try? JSONDecoder().decode(Block.self, from: data) {
            blockchainDelegate?.addBlockToBlockchain(block: block)
        }
        
        if let transaction = try? JSONDecoder().decode(Transaction.self, from: data) {
            blockchainDelegate?.mineBlock(transaction: transaction)
        }
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
