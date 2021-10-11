//
//  InformationView.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 11/10/21.
//

import Foundation
import UIKit

final class InformationView: UIStackView {
    
    // MARK: - Internal properties
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var text: String = "" {
        didSet {
            textLabel.text = text
        }
    }
    
    // MARK: - Private methods
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
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
        alignment = .leading
        distribution = .fill
        spacing = 4
        
        addArrangedSubview(titleLabel)
        addArrangedSubview(textLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
    }
}
