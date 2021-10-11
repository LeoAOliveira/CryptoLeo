//
//  SessionRole.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 10/10/21.
//

import Foundation

/// Roles that the peers play in a multi-peer local network session.
///
/// Even though there are host and guests roles, they are purely for organizing the session lobby
/// and to kickstart a blockchain with a genesis block. The session is still decentralized, without
/// third parties intermediating transactions and blocks mining.
enum SessionRole {
    
    /// The one who is organizing the session and responsible for mining the genesis block.
    case host
    
    /// Who joins a multi-pee local network session.
    case guest
}
