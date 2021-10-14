//
//  AppIntroViewController.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 13/10/21.
//

import Foundation
import UIKit
import CryptoKit

final class AppIntroViewController: UIViewController {
    
    let name: String
    let containerView: IntroView
    
    init(name: String) {
        self.name = name
        self.containerView = IntroView()
        super.init(nibName: nil, bundle: nil)
        bindViewEvents()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = containerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.text = "Olá, \(name)! \(CryptoLeoStrings.appIntro)"
        containerView.buttonTitle = CryptoLeoStrings.initialize
        
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    private func bindViewEvents() {
        
        containerView.didTapButton = { [weak self] in
            self?.presentSessionAlert()
        }
    }
    
    private func presentSessionAlert() {
        
        let title = CryptoLeoStrings.sessionRole
        let description = CryptoLeoStrings.sessionRoleDescription
        
        let alert = AlertFactory.createTwoButtonsAlert(title: title,
                                                       description: description) { [weak self] sessionRole in
            self?.pushToLobbyViewController(sessionRole: sessionRole)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func pushToLobbyViewController(sessionRole: SessionRole) {
        
        let privateKey = Curve25519.Signing.PrivateKey()
        let publicKey = privateKey.publicKey.rawRepresentation
        let user = Peer(name: name, uuid: UUID().uuidString, publicKey: publicKey)
        
        let controller = LobbyViewController(sessionRole: sessionRole, userPeer: user)
        
        navigationController?.pushViewController(controller, animated: true)
    }
}
