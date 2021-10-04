//
//  InvalidBlockKey.swift
//  Crypto Leo
//
//  Created by Leonardo Oliveira on 03/10/21.
//

import Foundation

enum CryptoLeoError: Error {
    case failedToMineBlock
    case blockIsAlreadyMined
}
