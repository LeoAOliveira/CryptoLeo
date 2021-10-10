//
//  BlockchainBroadcaster.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 10/10/21.
//

import Foundation
import MultipeerConnectivity

/// Object responsible to broadcast blockchain-related events to all connected peers in the local network.
final class BlockchainBroadcaster {
    
    // MARK: - Private properties
    
    /// Multi-peer session that enables the blockchain peer-to-peer communication.
    private let mcSession: MCSession
    
    // MARK: - Initializers
    
    /// Initializes a `BlockchainBroadcaster`.
    /// - Parameter mcSession: Multi-peer session.
    init(mcSession: MCSession) {
        self.mcSession = mcSession
    }
    
    // MARK: - Internal methods
    
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
    
    // MARK: - Private methods
    
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
}
