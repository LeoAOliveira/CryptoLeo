//
//  BlockchainSession.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 06/10/21.
//

import Foundation
import CryptoKit
import MultipeerConnectivity

final class BlockchainSession: NSObject {
    
    weak var controller: BlockchainViewController?
    
    var mineTransaction: ((Transaction) -> Void)?
    
    private let mcSession: MCSession
    
    init(mcSession: MCSession) {
        self.mcSession = mcSession
    }
    
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
    
    private func decodeReceivedData(data: Data) {
        
        if let blockchain = try? JSONDecoder().decode(Blockchain.self, from: data) {
            controller?.updateBlockchain(with: blockchain)
        }
        
        if let block = try? JSONDecoder().decode(Block.self, from: data) {
            controller?.addBlockToBlockchain(block: block)
        }
        
        if let transaction = try? JSONDecoder().decode(Transaction.self, from: data) {
            controller?.mineBlock(transaction: transaction)
        }
    }
}

extension BlockchainSession: MCSessionDelegate {
    
    func session(_ session: MCSession,
                 peer peerID: MCPeerID,
                 didChange state: MCSessionState) {
        
        switch state {
        
        case MCSessionState.connected:
            
            guard let blockchain = controller?.transactor.blockchain else {
                return
            }
            
            broadcast(information: .currentBlockchain(blockchain))
            
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
                 fromPeer peerID: MCPeerID,
                 at localURL: URL?,
                 withError error: Error?) { }
}

extension BlockchainSession: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        controller?.dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        controller?.dismiss(animated: true)
    }
}
