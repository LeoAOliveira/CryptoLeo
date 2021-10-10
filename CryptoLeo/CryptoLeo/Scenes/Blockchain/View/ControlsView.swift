//
//  ControlsView.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 10/10/21.
//

import Foundation
import UIKit

final class ControlsView: UIStackView {
    
    // MARK: - Internal properties
    
    var didTapTransfer: (() -> Void)?
    var didTapBlockchain: (() -> Void)?
    var didTapAbout: (() -> Void)?
    var didTapConnection: (() -> Void)?
    var didChangeSwitch: ((Bool) -> Void)?
    
    // MARK: - Private properties
    
    private let miningSwitch = MineSwitchView()
    
    private let transactionButton: ControlButton = {
        let button = ControlButton()
        button.title = "Transferir"
        button.image = UIImage(systemName: "dollarsign.circle")
        return button
    }()
    
    private let blockchainButton: ControlButton = {
        let button = ControlButton()
        button.title = "Blockchain"
        button.image = UIImage(systemName: "cube")
        return button
    }()
    
    private let aboutButton: ControlButton = {
        let button = ControlButton()
        button.title = "Sobre"
        button.image = UIImage(systemName: "info.circle")
        return button
    }()
    
    private let connectionButton: ControlButton = {
        let button = ControlButton()
        button.title = "Conexão"
        button.image = UIImage(systemName: "iphone.radiowaves.left.and.right")
        return button
    }()
    
    private let firstRowStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fillEqually
        view.spacing = 20
        return view
    }()
    
    private let secondRowStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fillEqually
        view.spacing = 20
        return view
    }()
    
    private let mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .equalSpacing
        view.spacing = 20
        return view
    }()
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    /// Unavailable required initializer.
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setup() {
        
        axis = .vertical
        alignment = .fill
        distribution = .equalSpacing
        spacing = 20
        
        buildView()
        bindViewEvents()
    }
    
    private func buildView() {
        
        transactionButton.translatesAutoresizingMaskIntoConstraints = false
        blockchainButton.translatesAutoresizingMaskIntoConstraints = false
        aboutButton.translatesAutoresizingMaskIntoConstraints = false
        connectionButton.translatesAutoresizingMaskIntoConstraints = false
        miningSwitch.translatesAutoresizingMaskIntoConstraints = false
        firstRowStackView.translatesAutoresizingMaskIntoConstraints = false
        secondRowStackView.translatesAutoresizingMaskIntoConstraints = false
        
        firstRowStackView.addArrangedSubview(transactionButton)
        firstRowStackView.addArrangedSubview(blockchainButton)
        
        secondRowStackView.addArrangedSubview(aboutButton)
        secondRowStackView.addArrangedSubview(connectionButton)
        
        addArrangedSubview(firstRowStackView)
        addArrangedSubview(secondRowStackView)
        addArrangedSubview(miningSwitch)
    }
    
    private func bindViewEvents() {
        
        transactionButton.didTapButton = { [weak self] in
            self?.didTapTransfer?()
        }
        
        blockchainButton.didTapButton = { [weak self] in
            self?.didTapBlockchain?()
        }
        
        aboutButton.didTapButton = { [weak self] in
            self?.didTapAbout?()
        }
        
        connectionButton.didTapButton = { [weak self] in
            self?.didTapConnection?()
        }
        
        miningSwitch.didChangeSwitch = { [weak self] isOn in
            self?.didChangeSwitch?(isOn)
        }
    }
}
