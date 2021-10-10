//
//  CryptoLeoError.swift
//  Crypto Leo
//
//  Created by Leonardo Oliveira on 03/10/21.
//

import Foundation

/// All possible errors that can happen in the app.
enum CryptoLeoError: Error {
    
    // Signature errors
    case failedToSignTransaction
    case transactionIsNotSigned
    case transactionSignatureIsInvalid
    
    // Mining errors
    case blockIsNotMined
    case blockIsAlreadyMined
    
    // Block errors
    case blockHasInvalidHash
    case blockDoesNotHaveStoredTransaction
    
    // Broadcast errors
    case failedToCastAsData
    case failedToSendData
}
