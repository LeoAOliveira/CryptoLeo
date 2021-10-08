//
//  ViewController.swift
//  Crypto Leo
//
//  Created by Leonardo Oliveira on 27/09/21.
//

import UIKit
import CryptoKit
import MultipeerConnectivity

final class ViewController: UIViewController {
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    var sessionDelegate: BlockchainSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        
        example()
    }
    
    private func example() {

        // Necessary information

        let privateKey1 = Curve25519.Signing.PrivateKey()
        let person1 = Peer(name: "Leo", publicKey: privateKey1.publicKey.rawRepresentation)
        
        let privateKey2 = Curve25519.Signing.PrivateKey()
        let person2 = Peer(name: "Rick", publicKey: privateKey2.publicKey.rawRepresentation)
        
        // Blockchain
        
        let transactor = Transactor(name: "Leo's Blockchain", creator: person1, session: mcSession)
        
        transactor.didCreateBlockchain = {
            print("\n===================\nBlockchain created!\n===================\n\n")
        }
        
        // Transaction
        
        do {
            try transactor.sendTransaction(amount: 100,
                                           receiver: person2,
                                           mineOwnBlock: true)
        } catch {
            print(error.localizedDescription)
        }
        
    }
}

