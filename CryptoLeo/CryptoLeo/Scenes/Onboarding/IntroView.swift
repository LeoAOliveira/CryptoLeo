//
//  IntroView.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 13/10/21.
//

import Foundation
import UIKit

final class IntroView: UIView {
    
    var didTapButton: (() -> Void)?
    
    var text: String = "" {
        didSet {
            textLabel.text = text
        }
    }
    
    var buttonTitle: String = "" {
        didSet {
            button.setTitle(buttonTitle, for: .normal)
        }
    }
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        label.textColor = .label
        label.text = "Bem-vind@"
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.text = "CryptoLeo"
        return label
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "CryptoLeo"
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .fill
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
    
    private func setup() {
        
        buildView()
        addConstraints()
        
        button.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        backgroundColor = .tertiarySystemBackground
    }
    
    private func buildView() {
        mainStackView.addArrangedSubview(welcomeLabel)
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(textLabel)
        addSubview(mainStackView)
        addSubview(button)
    }
    
    private func addConstraints() {
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            mainStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            mainStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            mainStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            
            button.heightAnchor.constraint(equalToConstant: 40),
            button.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            button.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40)
        ])
    }
    
    @objc
    private func buttonHandler() {
        didTapButton?()
    }
}
