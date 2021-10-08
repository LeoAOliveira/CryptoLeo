//
//  BroadcastInformation.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 08/10/21.
//

import Foundation

enum BroadcastInformation {
    case currentBlockchain(Blockchain)
    case newBlock(Block)
    case newTransaction(Transaction)
}
