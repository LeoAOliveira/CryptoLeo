//
//  MineSwitchView.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 10/10/21.
//

import Foundation
import UIKit

final class MineSwitchView: UIView {
    
    var didChangeSwitch: ((Bool) -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.textAlignment = .left
        label.text = "Minerar blocos"
        return label
    }()
    
    private let miningSwitch: UISwitch = {
        let miningSwitch = UISwitch()
        miningSwitch.target(forAction: #selector(miningSwitchHandler), withSender: nil)
        miningSwitch.isOn = true
        return miningSwitch
    }()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    /// Unavailable required initializer.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        layer.cornerRadius = 12
        backgroundColor = .tertiarySystemBackground
        
        buildView()
        addConstraints()
    }
    
    private func buildView() {
        addSubview(titleLabel)
        addSubview(miningSwitch)
    }
    
    private func addConstraints() {
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        miningSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
            titleLabel.rightAnchor.constraint(equalTo: miningSwitch.leftAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            miningSwitch.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            miningSwitch.rightAnchor.constraint(equalTo: rightAnchor, constant: -12),
            miningSwitch.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    @objc
    private func miningSwitchHandler() {
        didChangeSwitch?(miningSwitch.isOn)
    }
}
