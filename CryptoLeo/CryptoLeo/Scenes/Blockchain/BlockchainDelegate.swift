//
//  BlockchainDelegate.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 10/10/21.
//

import Foundation

protocol BlockchainDelegate: AnyObject {
    func updateBlockchain(with blockchain: Blockchain)
    func addBlockToBlockchain(block: Block)
    func mineBlock(transaction: Transaction)
    func getCurrentBlockchain() -> Blockchain
}
