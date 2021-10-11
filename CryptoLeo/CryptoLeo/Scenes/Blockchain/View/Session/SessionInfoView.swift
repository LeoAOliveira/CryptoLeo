//
//  SessionInfoView.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 11/10/21.
//

import Foundation
import UIKit

final class SessionInfoView: UIStackView {
    
    // MARK: - Internal properties
    
    var text: String = "" {
        
        didSet {
            captionLabel.text = text
        }
    }
    
    var infoNumber: Int = 0 {
        
        didSet {
            DispatchQueue.main.async {
                self.imageView.image = UIImage(systemName: "\(self.infoNumber).square")
            }
        }
    }
    
    // MARK: - Private properties
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption2)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "0.square")
        return imageView
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
        alignment = .center
        distribution = .fill
        spacing = 8
        
        buildView()
        addConstraints()
    }
    
    private func buildView() {
        addArrangedSubview(imageView)
        addArrangedSubview(captionLabel)
    }
    
    private func addConstraints() {
        
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 32),
            imageView.widthAnchor.constraint(equalToConstant: 32)
        ])
    }
}
