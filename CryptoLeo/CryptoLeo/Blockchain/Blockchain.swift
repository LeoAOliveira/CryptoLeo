//
//  Blockchain.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 05/10/21.
//

import Foundation

final class Blockchain {
    
    var creationCompleted: (() -> Void)?
    
    let name: String
    
    private(set) var blocks: [BlockType] = [BlockType]()
    
    init(name: String, creator: Peer) {
        self.name = name
        createGenesisBlock(miner: creator)
    }
    
    private func createGenesisBlock(miner: Peer) {
        
        let genesisBlock = GenesisBlock()
        
        genesisBlock.mine(miner: miner) { [weak self] in
            self?.blocks.append(genesisBlock)
            self?.creationCompleted?()
        }
    }
    
    func addBlock(_ block: Block) throws {
        
        if block.hash == nil {
            throw CryptoLeoError.blockIsNotMined
        }
        
        blocks.append(block)
    }
}
