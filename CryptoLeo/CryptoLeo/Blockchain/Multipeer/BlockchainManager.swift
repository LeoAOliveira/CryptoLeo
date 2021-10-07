//
//  BlockchainManager.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 05/10/21.
//

import Foundation
import MultipeerConnectivity

final class BlockchainManager {
    
    var creationCompleted: (() -> Void)?
    
    private(set) var blockchain: Blockchain
    
    private let session: MCSession
    
    init(name: String, creator: Peer, session: MCSession) {
        self.blockchain = Blockchain(name: name, blocks: [])
        self.session = session
        createGenesisBlock(miner: creator)
    }
    
    private func createGenesisBlock(miner: Peer) {
        
        let genesisBlock = GenesisBlock()
        
        genesisBlock.mine(miner: miner) { [weak self] in
            self?.blockchain.blocks.append(genesisBlock)
            self?.creationCompleted?()
        }
    }
    
//    private func broadcast(newBlock: BlockType) {
//
//        var blocksString: String
//
//        for block in blockchain.blocks {
//            blocksString += "\(block.key)"
//        }
//    }
    
    func addBlock(_ block: Block) throws {
        
        if block.hash == nil {
            throw CryptoLeoError.blockIsNotMined
        }
        
        if block.previousHash != blockchain.blocks.last?.previousHash {
            throw CryptoLeoError.previousHashIsIncorrect
        }
        
        blockchain.blocks.append(block)
    }
    
    func updateBlockchain(incomingBlock: BlockType) {
        blockchain.blocks.append(incomingBlock)
    }
}
