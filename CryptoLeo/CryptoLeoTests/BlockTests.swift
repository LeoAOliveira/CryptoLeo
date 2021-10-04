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
    
    let previousIndex: Int = 0
    let previousHash: SHA256Digest = SHA256.hash(data: "00000".data(using: .utf8)!)
    let miner: String = "Leo"
    let privateKey: String = "12345"
    
    override func setUp() {
        super.setUp()
        transaction = Transaction(sender: "Leonardo", receiver: "Ricardo", amount: 10, privateKey: "12345")
        sut = Block(transaction: transaction)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - mine(previousIndex:previousHash:miner:privateKey:)
    
    func testMineSuccess() {
        
        sut.mine(previousIndex: previousIndex,
                 previousHash: previousHash,
                 miner: miner,
                 privateKey: privateKey) { result in
            
            // Result
            XCTAssertEqual(result, .success(true))
            
            // Index
            XCTAssertEqual(sut.index, 1)
            
            // Previous Hash
            XCTAssertNotNil(sut.previousHash)
            
            // Reward
            XCTAssertNotNil(sut.reward)
            XCTAssertNil(sut.reward?.sender)
            XCTAssertEqual(sut.reward?.receiver, "Leo")
            XCTAssertEqual(sut.reward?.amount, 10)
            
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
                 privateKey: privateKey) { result in
            
            XCTAssertEqual(result, .failure(.blockIsAlreadyMined))
        }
    }
    
    private func createHashString(digest: SHA256Digest) -> String {
        return digest.compactMap({ String(format: "%02x", $0) }).joined()
    }
}
