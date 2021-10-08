//
//  Peer.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 04/10/21.
//

import Foundation

/// Node of the blockchain, which is able to transfer cryptocurrency or mine blocks and be rewarded.
///
/// - **Name**: Person's name.
/// - **Public Key**: Personal public key, used for verifying transaction's signatures.
struct Peer: Codable, Equatable {
    
    /// Peer's name.
    let name: String
    
    /// Peer's public key, used for verifying transaction's signatures.
    let publicKey: Data
}
