//
//  SessionView.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 11/10/21.
//

import Foundation
import UIKit

final class SessionView: UIView {
    
    // MARK: - Internal properties
    
    var blockchainInfoNumber: Int = 0 {
        didSet {
            blockchainInfoView.infoNumber = blockchainInfoNumber
        }
    }
    
    var minedBlocksInfoNumber: Int = 0 {
        didSet {
            minedBlocksInfoView.infoNumber = minedBlocksInfoNumber
        }
    }
    
    var sentTransactionsInfoNumber: Int = 0 {
        didSet {
            sentTransactionsInfoView.infoNumber = sentTransactionsInfoNumber
        }
    }
    
    var receivedTransactionsInfoNumber: Int = 0 {
        didSet {
            receivedTransactionsInfoView.infoNumber = receivedTransactionsInfoNumber
        }
    }
    
    // MARK: - Private properties
    
    private let blockchainInfoView: SessionInfoView = {
        let view = SessionInfoView()
        view.text = "Blocos no\nblockchain"
        return view
    }()
    
    private let minedBlocksInfoView: SessionInfoView = {
        let view = SessionInfoView()
        view.text = "Blocos\nminerados"
        return view
    }()
    
    private let sentTransactionsInfoView: SessionInfoView = {
        let view = SessionInfoView()
        view.text = "Transações\nenviadas"
        return view
    }()
    
    private let receivedTransactionsInfoView: SessionInfoView = {
        let view = SessionInfoView()
        view.text = "Transações\nrecebidas"
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.textAlignment = .left
        label.text = "Resumo da sessão"
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fillEqually
        view.spacing = 8
        return view
    }()
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    /// Unavailable required initializer.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setup() {
        
        layer.cornerRadius = 12
        backgroundColor = .tertiarySystemBackground
        
        buildView()
        addConstraints()
    }
    
    private func buildView() {
        
        infoStackView.addArrangedSubview(blockchainInfoView)
        infoStackView.addArrangedSubview(minedBlocksInfoView)
        infoStackView.addArrangedSubview(sentTransactionsInfoView)
        infoStackView.addArrangedSubview(receivedTransactionsInfoView)
        
        addSubview(infoStackView)
        addSubview(titleLabel)
    }
    
    private func addConstraints() {
        
        blockchainInfoView.translatesAutoresizingMaskIntoConstraints = false
        minedBlocksInfoView.translatesAutoresizingMaskIntoConstraints = false
        sentTransactionsInfoView.translatesAutoresizingMaskIntoConstraints = false
        receivedTransactionsInfoView.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -12),
            
            infoStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            infoStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
            infoStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12),
            infoStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
