//
//  LobbyDelegate.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 10/10/21.
//

import Foundation

/// Protocol responsible for delegating multi-peer session's lobby related events
protocol LobbyDelegate: AnyObject {
    func connectNewPeerToSession()
    func startSession()
}
