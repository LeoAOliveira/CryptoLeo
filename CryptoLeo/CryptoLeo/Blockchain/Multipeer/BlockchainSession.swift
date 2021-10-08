//
//  BlockchainSession.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 06/10/21.
//

import Foundation
import MultipeerConnectivity

final class BlockchainSession: NSObject {
    
//    let blockchainManager: BlockchainManager
//    
//    init(blockchainManager: BlockchainManager) {
//        self.blockchainManager = blockchainManager
//    }
    
    private func updateBlockchain(with data: Data) {
        
        
        
//        guard let newBlock = try? JSONDecoder().decode(BlockType.self, from: data) else {
//            return
//        }
//        
//        blockchain.updateBlockchain(incomingBlock: newBlock)
    }
}

extension BlockchainSession: MCSessionDelegate {
    
    func session(_ session: MCSession,
                 peer peerID: MCPeerID,
                 didChange state: MCSessionState) {
        
        switch state {
        
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            
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
        
        updateBlockchain(with: data)
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
                 fromPeer peerID: MCPeerID,
                 at localURL: URL?,
                 withError error: Error?) { }
}
