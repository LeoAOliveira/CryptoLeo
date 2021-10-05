//
//  Reward.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 04/10/21.
//

import Foundation
import CryptoKit

final class Reward {
    
    /// Peer that's being rewarded with cryptocurrency.
    let miner: Peer
    
    /// Amount of cryptocurrency that the miner is being rewarded with.
    let amount: Double = 5
    
    /// When the transaction is being made.
    let timestamp: Timestamp = Timestamp()
    
    /// Reward message.
    private(set) lazy var message: String = createMessage()
    
    /// Signature that validates the reward.
    private(set) var signature: Data? = nil
    
    /// Initializes a reward.
    /// - Parameter miner: Peer that's being rewarded with cryptocurrency.
    init(miner: Peer) {
        self.miner = miner
    }
    
    /// Signs the reward.
    /// - Parameter privateKey: Miner's private key, that will be used to sign the reward.
    /// - Parameter completion: Result of the signing.
    func sign(with privateKey: Curve25519.Signing.PrivateKey, completion: (Result<Bool, CryptoLeoError>) -> Void) {
        
        let signature = DigitalSignature.sign(message: message, privateKey: privateKey, publicKey: miner.publicKey)
        
        if signature != nil {
            self.signature = signature
            completion(.success(true))
            
        } else {
            completion(.failure(.failedToSignReward))
        }
    }
    
    /// Creates a message describing the reward.
    /// - Returns: Message describing the reward.
    private func createMessage() -> String {
        return "\(miner) gets L$ \(amount) for mining the block on \(timestamp.date)"
    }
}
