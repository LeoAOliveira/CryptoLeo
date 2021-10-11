//
//  BlockCell.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 11/10/21.
//

import Foundation
import UIKit

final class BlockCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let blockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "0.square")
        return imageView
    }()
    
    private let hashView: InformationView = {
        let view = InformationView()
        view.title = "Hash"
        return view
    }()
    
    private let previousHashView: InformationView = {
        let view = InformationView()
        view.title = "Hash do bloco anterior"
        return view
    }()
    
    private let transactionView: InformationView = {
        let view = InformationView()
        view.title = "Transação"
        return view
    }()
    
    private let miningView: InformationView = {
        let view = InformationView()
        view.title = "Mineração"
        return view
    }()
    
    private let nonceView: InformationView = {
        let view = InformationView()
        view.title = "Nonce (prova de trabalho)"
        return view
    }()
    
    private let genesisView: InformationView = {
        let view = InformationView()
        view.title = "Bloco Gênesis"
        return view
    }()
    
    private let mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .equalSpacing
        view.spacing = 12
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setup()
    }
    
    /// Unavailable required initializer.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with block: Block) {
        
        blockImageView.image = UIImage(systemName: "\(block.index).square")
        
        hashView.text = block.hash
        
        if block.index == 0 {
            
            mainStackView.removeArrangedSubview(previousHashView)
            mainStackView.removeArrangedSubview(transactionView)
            mainStackView.removeArrangedSubview(miningView)
            mainStackView.removeArrangedSubview(nonceView)
            
            mainStackView.addArrangedSubview(genesisView)
            genesisView.text = block.key
            
        } else {
            
            mainStackView.removeArrangedSubview(genesisView)
            
            mainStackView.addArrangedSubview(previousHashView)
            mainStackView.addArrangedSubview(transactionView)
            mainStackView.addArrangedSubview(miningView)
            mainStackView.addArrangedSubview(nonceView)
            
            previousHashView.text = block.previousHash ?? ""
            transactionView.text = block.transaction?.message ?? ""
            miningView.text = block.reward?.message ?? ""
            nonceView.text = "\(block.nonce)"
        }
    }
    
    private func setup() {
        buildView()
        addConstraints()
        backgroundColor = .secondarySystemBackground
    }
    
    private func buildView() {
        mainStackView.addArrangedSubview(hashView)
        containerView.addSubview(blockImageView)
        containerView.addSubview(mainStackView)
        addSubview(containerView)
    }
    
    private func addConstraints() {
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        blockImageView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        genesisView.translatesAutoresizingMaskIntoConstraints = false
        previousHashView.translatesAutoresizingMaskIntoConstraints = false
        transactionView.translatesAutoresizingMaskIntoConstraints = false
        miningView.translatesAutoresizingMaskIntoConstraints = false
        nonceView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            blockImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            blockImageView.heightAnchor.constraint(equalToConstant: 40),
            blockImageView.widthAnchor.constraint(equalToConstant: 40),
            blockImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            
            mainStackView.topAnchor.constraint(equalTo: blockImageView.bottomAnchor, constant: 12),
            mainStackView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12),
            mainStackView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -12),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
}
