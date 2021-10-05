//
//  BlockTests.swift
//  Crypto LeoTests
//
//  Created by Leonardo Oliveira on 27/09/21.
//

import XCTest
import CryptoKit

@testable import CryptoLeo

final class BlockTests: XCTestCase {
    
    var sut: Block!
    var transaction: Transaction!
    var miner: Peer!
    
    let previousIndex: Int = 0
    let previousHash: SHA256Digest = SHA256.hash(data: "00000".data(using: .utf8)!)
    
    let privateKey1 = Curve25519.Signing.PrivateKey()
    let privateKey2 = Curve25519.Signing.PrivateKey()
    
    override func setUp() {
        super.setUp()
        
        let person1 = Peer(name: "Leo", publicKey: privateKey1.publicKey.rawRepresentation)
        let person2 = Peer(name: "Rick", publicKey: privateKey2.publicKey.rawRepresentation)
        
        transaction = Transaction(sender: person1,
                                  receiver: person2,
                                  amount: 100)
        
        sut = Block(transaction: transaction)
        miner = person1
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - mine(previousIndex:previousHash:miner:privateKey:)
    
    func testMineSuccess() {
        
        sut.mine(previousIndex: previousIndex,
                 previousHash: previousHash,
                 miner: miner,
                 privateKey: privateKey1) { result in
            
            // Result
            XCTAssertEqual(result, .success(true))
            
            // Index
            XCTAssertEqual(sut.index, 1)
            
            // Previous Hash
            XCTAssertNotNil(sut.previousHash)
            
            // Reward
            XCTAssertNotNil(sut.reward)
            XCTAssertEqual(sut.reward?.miner.name, "Leo")
            XCTAssertEqual(sut.reward?.miner.publicKey, privateKey1.publicKey.rawRepresentation)
            XCTAssertEqual(sut.reward?.amount, 5)
            
            // Hash
            let hashString = createHashString(digest: sut.hash!)
            XCTAssertEqual(hashString.hasPrefix("000"), true)
        }
    }
    
    func testMineFailsAlreadyMined() {
        
        sut.availableForMining = false
        
        sut.mine(previousIndex: previousIndex,
                 previousHash: previousHash,
                 miner: miner,
                 privateKey: privateKey1) { result in
            
            XCTAssertEqual(result, .failure(.blockIsAlreadyMined))
        }
    }
    
    private func createHashString(digest: SHA256Digest) -> String {
        return digest.compactMap({ String(format: "%02x", $0) }).joined()
    }
}
