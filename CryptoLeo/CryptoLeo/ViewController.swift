//
//  ViewController.swift
//  Crypto Leo
//
//  Created by Leonardo Oliveira on 27/09/21.
//

import UIKit
import CryptoKit

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        example()
    }
    
    private func example() {
        
        // Necessary information
        
        let privateKey1 = Curve25519.Signing.PrivateKey()
        let person1 = Peer(name: "Leo", publicKey: privateKey1.publicKey.rawRepresentation)

        let privateKey2 = Curve25519.Signing.PrivateKey()
        let person2 = Peer(name: "Rick", publicKey: privateKey2.publicKey.rawRepresentation)
        
        // Blockchain
        
        let blockchain = Blockchain(name: "Leo's Blockchain", creator: person1)
        
        blockchain.creationCompleted = {
            print("\n===================\nBlockchain created!\n===================\n\n")
        }
        
        // Transaction

        let transaction = Transaction(sender: person1, receiver: person2, amount: 100)
        print("CREATED TRANSACTION\nMessage: \(transaction.message)\n\n")

        do {
            try transaction.sign(privateKey: privateKey1, publicKey: person1.publicKey)
            print("SIGNED TRANSACTION\nSignature: \(String(describing: transaction.signature))\n\n")
        } catch let error {
            print(error.localizedDescription)
        }
        
        // Block

        let block = Block(transaction: transaction)
        print("CREATED BLOCK\n\n")
        
        print("MINING BLOCK...\n\n")

        block.mine(previousIndex: (blockchain.blocks.last?.index)!,
                   previousHash: (blockchain.blocks.last?.hash)!,
                   miner: person1,
                   privateKey: privateKey1) { result in

            switch result {
            
            case .success:
                print("BLOCK MINED!\n\(block.key)\n\n")
                
            case .failure(let fail):
                print(fail)
            }
        }
        
        // Register transaction
        
        do {
            try blockchain.addBlock(block)
            print("ADDED BLOCK TO THE BLOCKCHAIN!\n\n")
        } catch {
            print(error.localizedDescription)
        }
        
        print("BLOCKCHAIN:\n")
        
        for block in blockchain.blocks {
            print("\(block.key)\n")
        }
    }
}

