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
        
        let privateKey1 = Curve25519.Signing.PrivateKey()
        let person1 = Peer(name: "Leo", publicKey: privateKey1.publicKey.rawRepresentation)

        let privateKey2 = Curve25519.Signing.PrivateKey()
        let person2 = Peer(name: "Rick", publicKey: privateKey2.publicKey.rawRepresentation)

        let transaction = Transaction(sender: person1, receiver: person2, amount: 100)

        do {
            try transaction.sign(privateKey: privateKey1, publicKey: person1.publicKey)
        } catch let error {
            print(error.localizedDescription)
        }

        let block = Block(transaction: transaction)

        let keyData = "key".data(using: .utf8)!
        let hash = SHA256.hash(data: keyData)

        block.mine(previousIndex: .random(in: 0...100),
                   previousHash: hash,
                   miner: person1,
                   privateKey: privateKey1) { result in

            switch result {
            
            case .success:
                print("\nRESULT:\n")
                print(block.key)
                
            case .failure(let fail):
                print(fail)
            }
        }
    }
}

