//
//  LoadingView.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 10/10/21.
//

import Foundation
import UIKit

final class LoadingView: UIView {
    
    var hasFadeInAnimation: Bool = false
    
    var titleText: String = "" {
        
        didSet {
            if canEditText {
                titleLabel.text = titleText
            }
        }
    }
    
    var subtitleText: String = "" {
        
        didSet {
            subtitleLabel.text = subtitleText
            
            if let text = subtitleLabel.text, text.contains("iterações") {
                titleText = "Bloco minerado com sucesso"
                canEditText = false
                fadeOutAnimation()
            }
        }
    }
    
    var activityIndicatorIsHidden: Bool = false {
        
        didSet {
            if activityIndicatorIsHidden {
                activityIndicator.stopAnimating()
            } else {
                activityIndicator.startAnimating()
            }
        }
    }
    
    var hide: Bool = true {
        
        didSet {
            if !hide && hasFadeInAnimation {
                fadeInAnimation()
            } else if hide {
                fadeOutAnimation()
            }
        }
    }
    
    private var canEditText = true
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let blurEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemUltraThinMaterial)
        return UIVisualEffectView(effect: effect)
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.text = titleText
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFMono-Regular", size: 17)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        label.text = " "
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    deinit {
        activityIndicator.stopAnimating()
    }
    
    /// Unavailable required initializer.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        buildView()
        addConstraints()
    }
    
    private func buildView() {
        addSubview(blurEffectView)
        addSubview(stackView)
        stackView.addArrangedSubview(activityIndicator)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
    }
    
    private func addConstraints() {
        
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.leftAnchor.constraint(equalTo: leftAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    private func fadeInAnimation() {
        
        if !activityIndicatorIsHidden {
            activityIndicator.startAnimating()
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) { [weak self] in
            self?.alpha = 1
        }
    }
    
    private func fadeOutAnimation() {
        
        UIView.animate(withDuration: 0.25, delay: 4, options: .curveEaseIn) { [weak self] in
            self?.alpha = 0
        } completion: { [weak self] _ in
            self?.activityIndicator.stopAnimating()
        }
    }
}
