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
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .white
        buildView()
        addConstraints()
        addActions()
    }
    
    private func buildView() {
        addSubview(button)
    }
    
    private func addConstraints() {
        
        NSLayoutConstraint.activate([
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
