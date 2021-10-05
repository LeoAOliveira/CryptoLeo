//
//  CryptoLeoError.swift
//  Crypto Leo
//
//  Created by Leonardo Oliveira on 03/10/21.
//

import Foundation

enum CryptoLeoError: Error {
    
    // Signature errors
    case failedToSignTransaction
    case transactionIsNotSigned
    
    // Mining errors
    case blockIsAlreadyMined
}
