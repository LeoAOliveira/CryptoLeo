//
//  TransactionView.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 10/10/21.
//

import Foundation
import UIKit
import MultipeerConnectivity

final class TransactionView: UIView {
    
    // MARK: - Internal properties
    
    var didTapTransfer: ((MCPeerID, Double) -> Void)?
    
    // MARK: - Private properties
    
    /// Peers connected in the local network session.
    private let peers: [MCPeerID]
    
    private var receiver: MCPeerID?
    
    private var amount: Double = 0.00
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Transação de\nCryptoLeo"
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Selecione o valor em CryptoLeo e uma pessoa conectada na sessão para realizar a transferência."
        return label
    }()
    
    private let transferButton: UIButton = {
        let button = UIButton()
        button.setTitle("Transferir", for: .normal)
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
    
    private lazy var peerPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    private lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Valor em CryptoLeo"
        textField.textAlignment = .center
        textField.backgroundColor = .tertiarySystemFill
        textField.layer.cornerRadius = 8
        textField.keyboardType = .decimalPad
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()
    
    // MARK: - Initializers
    
    /// Initializes a `TransactionView`.
    ///
    /// - Parameter peers: Peers connected in the session.
    init(peers: [MCPeerID]) {
        self.peers = peers
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
        buildView()
        addConstraints()
        addActions()
        setButtonVisibility()
        setupKeyboard()
        backgroundColor = .tertiarySystemBackground
    }
    
    private func buildView() {
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(descriptionLabel)
        mainStackView.addArrangedSubview(amountTextField)
        mainStackView.addArrangedSubview(peerPicker)
        addSubview(transferButton)
        addSubview(mainStackView)
    }
    
    private func addConstraints() {
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        peerPicker.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        transferButton.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            mainStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            mainStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            mainStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            
            amountTextField.heightAnchor.constraint(equalToConstant: 36),
            amountTextField.widthAnchor.constraint(equalTo: peerPicker.widthAnchor, multiplier: 0.95),
            
            transferButton.heightAnchor.constraint(equalToConstant: 40),
            transferButton.widthAnchor.constraint(equalTo: amountTextField.widthAnchor),
            transferButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            transferButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40)
        ])
        
        mainStackView.setCustomSpacing(32, after: titleLabel)
        mainStackView.setCustomSpacing(90, after: descriptionLabel)
        mainStackView.setCustomSpacing(0, after: amountTextField)
    }
    
    private func addActions() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UIView.endEditing(_:)))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
        
        transferButton.addTarget(self,
                                 action: #selector(transferButtonHandler),
                                 for: .touchUpInside)
    }
    
    private func setButtonVisibility() {
        let enabled = amountTextField.text != "" && amountTextField.text != "- Favorecido -" && receiver != nil
        transferButton.isUserInteractionEnabled = enabled
        transferButton.alpha = enabled ? 1 : 0.4
    }
    
    @objc
    private func transferButtonHandler() {
        
        guard let peer = receiver else {
            return
        }
        
        didTapTransfer?(peer, amount)
    }
}

// MARK: - UIPickerViewDataSource and UIPickerViewDelegate

extension TransactionView: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        
        return peers.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        if row == 0 {
            return "- Favorecido -"
        }
        
        return peers[row-1].displayName
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
        receiver = row == 0 ? nil : peers[row-1]
        setButtonVisibility()
    }
}

// MARK: - UITextFieldDelegate

extension TransactionView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.text == nil {
            textField.text = ""
            
        } else if let amount = Double(textField.text ?? "0") {
            self.amount = amount
            textField.text = "L$ \(String(format: "%.2f", amount))"
        }
        
        setButtonVisibility()
    }
}

// MARK: - Keyboard

extension TransactionView {
    
    private func setupKeyboard() {
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil,
                                        action: nil)
        
        let button = UIBarButtonItem(barButtonSystemItem: .done,
                                     target: self,
                                     action: #selector(keyboardButtonHandler))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.items = [flexSpace, button]
        toolbar.sizeToFit()
        toolbar.barStyle = .default
        
        amountTextField.inputAccessoryView = toolbar
        
    }
    
    @objc
    private func keyboardButtonHandler() {
        amountTextField.resignFirstResponder()
    }
}
