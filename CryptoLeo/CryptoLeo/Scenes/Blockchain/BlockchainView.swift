//
//  BlockchainView.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 09/10/21.
//

import Foundation
import UIKit

final class BlockchainView: UIView {
    
    var didTapTransfer: (() -> Void)?
    var didTapBlockchain: (() -> Void)?
    var didTapAbout: (() -> Void)?
    var didTapConnection: (() -> Void)?
    var didTapActivity: (() -> Void)?
    var didTapSwitch: ((Bool) -> Void)?
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Transferir", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    private let loadingView: LoadingView = {
        let view = LoadingView()
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setGenesisBlockLoading(isHidden: Bool, sessionRole: SessionRole? = nil) {
        
        loadingView.isHidden = isHidden
        
        guard let role = sessionRole else {
            return
        }
        
        if role == .host {
            loadingView.titleText = "Minerando o bloco gênesis"
            loadingView.activityIndicatorIsHidden = true
        
        } else {
            loadingView.titleText = "O host está minerando o bloco gênesis"
            loadingView.activityIndicatorIsHidden = false
        }
    }
    
    func updateLoadingProofOfWork(message: String) {
        
        if !loadingView.isHidden {
            loadingView.subtitleText = message
        }
    }
    
    private func setup() {
        backgroundColor = .white
        buildView()
        addConstraints()
        addActions()
    }
    
    private func buildView() {
        addSubview(button)
        addSubview(loadingView)
    }
    
    private func addConstraints() {
        
        button.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            loadingView.topAnchor.constraint(equalTo: topAnchor),
            loadingView.leftAnchor.constraint(equalTo: leftAnchor),
            loadingView.rightAnchor.constraint(equalTo: rightAnchor),
            loadingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func addActions() {
        button.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
    }
    
    @objc
    private func buttonHandler() {
        didTapTransfer?()
    }
}
