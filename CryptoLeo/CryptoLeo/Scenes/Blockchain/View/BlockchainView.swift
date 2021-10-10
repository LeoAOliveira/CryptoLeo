//
//  BlockchainView.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 09/10/21.
//

import Foundation
import UIKit

/// Object responsible for multi-peer blockchain session interface.
final class BlockchainView: UIView {
    
    var didTapTransfer: (() -> Void)?
    var didTapBlockchain: (() -> Void)?
    var didTapAbout: (() -> Void)?
    var didTapConnection: (() -> Void)?
    var didChangeSwitch: ((Bool) -> Void)?
    var didTapActivity: (() -> Void)?
    
    private let balanceView = BalanceView()
    private let controlsView = ControlsView()
    
    private let mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        return view
    }()
    
    private let loadingView: LoadingView = {
        let view = LoadingView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    /// Unavailable required initializer.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setGenesisBlockLoading(isHidden: Bool, sessionRole: SessionRole) {
        
        if sessionRole == .host {
            
            loadingView.titleText = isHidden ?
            "Mineração completada com sucesso" : "Minerando o bloco gênesis"
            
            loadingView.activityIndicatorIsHidden = true
        
        } else {
            loadingView.titleText = "O host está minerando o bloco gênesis"
            loadingView.activityIndicatorIsHidden = false
            loadingView.hide = isHidden
        }
    }
    
    func updateLoadingProofOfWork(message: String) {
        
        if !loadingView.isHidden {
            loadingView.subtitleText = message
        }
    }
    
    private func setup() {
        buildView()
        addConstraints()
        bindViewEvents()
        backgroundColor = .secondarySystemBackground
    }
    
    private func buildView() {
        
        mainStackView.addArrangedSubview(balanceView)
        mainStackView.addArrangedSubview(controlsView)
        
        addSubview(mainStackView)
        addSubview(loadingView)
    }
    
    private func addConstraints() {
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        balanceView.translatesAutoresizingMaskIntoConstraints = false
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            mainStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 28),
            mainStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            mainStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            
            loadingView.topAnchor.constraint(equalTo: topAnchor),
            loadingView.leftAnchor.constraint(equalTo: leftAnchor),
            loadingView.rightAnchor.constraint(equalTo: rightAnchor),
            loadingView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        mainStackView.setCustomSpacing(28, after: balanceView)
        mainStackView.setCustomSpacing(20, after: controlsView)
    }
    
    private func bindViewEvents() {
        
        controlsView.didTapTransfer = { [weak self] in
            self?.didTapTransfer?()
        }
        
        controlsView.didTapBlockchain = { [weak self] in
            self?.didTapBlockchain?()
        }
        
        controlsView.didTapAbout = { [weak self] in
            self?.didTapAbout?()
        }
        
        controlsView.didTapConnection = { [weak self] in
            self?.didTapConnection?()
        }
        
        controlsView.didChangeSwitch = { [weak self] isOn in
            self?.didChangeSwitch?(isOn)
        }
    }
}
