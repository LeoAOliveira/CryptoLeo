//
//  Peer.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 04/10/21.
//

import Foundation

struct Peer: Codable {
    
    /// Peer's name.
    let name: String
    
    /// Peer's public key.
    let publicKey: Data
}
