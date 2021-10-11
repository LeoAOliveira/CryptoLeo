//
//  BalanceView.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 10/10/21.
//

import Foundation
import UIKit

final class BalanceView: UIStackView {
    
    var amount: Double = 1000.00 {
        
        didSet {
            DispatchQueue.main.async {
                self.amountLabel.text = "L$ \(String(format: "%.2f", self.amount))"
            }
        }
    }
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "Saldo de CryptoLeo"
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "L$ 1000.00"
        return label
    }()
    
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
        spacing = 4
        
        buildView()
    }
    
    private func buildView() {
        
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addArrangedSubview(balanceLabel)
        addArrangedSubview(amountLabel)
    }
}
