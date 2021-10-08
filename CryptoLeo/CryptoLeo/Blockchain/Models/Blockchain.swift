//
//  Blockchain.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 06/10/21.
//

import Foundation

/// Blockchain model.
///
/// A blockchain contains:
/// - **Name**: Identifier given to the blockchain.
/// - **Block**: Array of blocks that compose the blockchain.
struct Blockchain: Codable, Equatable {
    
    /// Blockchain's given identifier.
    let name: String
    
    /// Array of `Block` that constitutes the blockchain (the chain it self).
    var blocks: [Block]
}
