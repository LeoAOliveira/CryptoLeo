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
    
    // MARK: - Internal properties
    
    var didTapTransfer: (() -> Void)?
    var didTapAudit: (() -> Void)?
    var didTapAbout: (() -> Void)?
    var didTapConnection: (() -> Void)?
    var didChangeSwitch: ((Bool) -> Void)?
    var didTapActivity: (() -> Void)?
    
    // MARK: - Private properties
    
    private let balanceView = BalanceView()
    private let sessionView = SessionView()
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
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    /// Unavailable required initializer.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func setGenesisBlockLoading(isHidden: Bool, sessionRole: SessionRole) {
        
        if sessionRole == .host {
            
            loadingView.titleText = "Minerando o bloco gênesis"
            
            loadingView.activityIndicatorIsHidden = true
        
        } else {
            loadingView.titleText = "O host está minerando o bloco gênesis"
            loadingView.activityIndicatorIsHidden = false
            loadingView.hide = isHidden
        }
    }
    
    func setMiningBlockLoading(isHidden: Bool) {
        
        loadingView.titleText = "Minerando bloco"
        loadingView.activityIndicatorIsHidden = true
        loadingView.hasFadeInAnimation = true
        loadingView.hide = isHidden
    }
    
    func updateLoadingProofOfWork(message: String) {
        
        if !loadingView.isHidden {
            loadingView.subtitleText = message
        }
    }
    
    func updateSessionInfo(sessionInfo: SessionInfo) {
        
        switch sessionInfo {
            
        case .blockchain:
            sessionView.blockchainInfoNumber += 1
            
        case .minedBlocks:
            sessionView.minedBlocksInfoNumber += 1
            
        case .transactionsSent:
            sessionView.sentTransactionsInfoNumber += 1
            
        case .transactionsReceived:
            sessionView.receivedTransactionsInfoNumber += 1
        }
    }
    
    func updateAmount(to amount: Double) {
        balanceView.amount = amount
    }
    
    // MARK: - Private methods
    
    private func setup() {
        buildView()
        addConstraints()
        bindViewEvents()
        backgroundColor = .secondarySystemBackground
    }
    
    private func buildView() {
        
        mainStackView.addArrangedSubview(balanceView)
        mainStackView.addArrangedSubview(sessionView)
        mainStackView.addArrangedSubview(controlsView)
        
        addSubview(mainStackView)
        addSubview(loadingView)
    }
    
    private func addConstraints() {
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        balanceView.translatesAutoresizingMaskIntoConstraints = false
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        sessionView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            mainStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 32),
            mainStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            mainStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            
            loadingView.topAnchor.constraint(equalTo: topAnchor),
            loadingView.leftAnchor.constraint(equalTo: leftAnchor),
            loadingView.rightAnchor.constraint(equalTo: rightAnchor),
            loadingView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        mainStackView.setCustomSpacing(40, after: balanceView)
        mainStackView.setCustomSpacing(32, after: sessionView)
        mainStackView.setCustomSpacing(32, after: controlsView)
    }
    
    private func bindViewEvents() {
        
        controlsView.didTapTransfer = { [weak self] in
            self?.didTapTransfer?()
        }
        
        controlsView.didTapAudit = { [weak self] in
            self?.didTapAudit?()
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
