//
//  AuditViewController.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 11/10/21.
//

import Foundation
import UIKit
import MultipeerConnectivity

/// Object responsible for controlling the audit screen, both logic and interface.
final class AuditViewController: UIViewController {
    
    // MARK: - Private properties
    
    /// View controlled by this class, responsible for the interface.
    private let containerView: AuditView
    
    // MARK: - Initializers
    
    /// Initializes a `AuditViewController` and a `AuditView`.
    ///
    /// - Parameter blockchain: The `Blockchain` model.
    init(blockchain: Blockchain) {
        self.containerView = AuditView(blockchain: blockchain)
        super.init(nibName: nil, bundle: nil)
        bindViewEvents()
    }
    
    /// Unavailable required initializer.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle methods
    
    /// Loads the view as the container view (of type `BlockchainView`).
    override func loadView() {
        view = containerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Auditoria"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // MARK: - Private methods
    
    private func bindViewEvents() {
        
        containerView.didSelectBlockAtIndex = { [weak self] index in
            self?.pushToBlockDetail(at: index)
        }
    }
    
    private func pushToBlockDetail(at index: Int) {
        
        print("Block \(index)")
    }
    
}
