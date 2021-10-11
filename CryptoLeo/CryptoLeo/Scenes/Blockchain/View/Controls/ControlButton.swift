//
//  ControlButton.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 10/10/21.
//

import Foundation
import UIKit

final class ControlButton: UIView {
    
    var didTapButton: (() -> Void)?
    
    var title: String = "" {
        
        didSet {
            titleLabel.text = title
        }
    }
    
    var image: UIImage? {
        
        didSet {
            iconImageView.image = image
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        addActions()
    }
    
    private func buildView() {
        addSubview(titleLabel)
        addSubview(iconImageView)
    }
    
    private func addConstraints() {
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
            iconImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 56),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func addActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(gestureHandler))
        addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func gestureHandler() {
        didTapButton?()
    }
}
