//
//  LobbyDelegate.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 10/10/21.
//

import Foundation

protocol LobbyDelegate: AnyObject {
    func connectNewPeerToSession()
    func startSession()
}
