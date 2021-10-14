//
//  AlertFactory.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 11/10/21.
//

import Foundation
import UIKit

/// Factory responsible for creating `UIAlertController`.
struct AlertFactory {
    
    /// Creates a default alert (one action) with the given information.
    ///
    /// - Parameter title: Alert's title.
    /// - Parameter description: Alert's description.
    /// - Parameter completion: Alert's completion closure, that will be executed when the user dismisses the alert.
    /// - Returns: A single button (default) customized `UIAlertController`.
    static func createDefaultAlert(title: String,
                                   description: String,
                                   completion: (() -> Void)? = nil) -> UIAlertController {
        
        let alert = UIAlertController(title: title,
                                      message: description,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Entendido", style: .default) { _ in
            completion?()
        }
        
        alert.addAction(action)
        
        return alert
    }
    
    /// Creates a two buttons alert with the given information.
    ///
    /// - Parameter title: Alert's title.
    /// - Parameter description: Alert's description.
    /// - Parameter completion: Alert's completion closure, that will be executed when the user dismisses the alert.
    /// - Returns: Two button customized `UIAlertController`.
    static func createTwoButtonsAlert(title: String,
                                      description: String,
                                      completion: ((SessionRole) -> Void)? = nil) -> UIAlertController {
        
        let alert = UIAlertController(title: title,
                                      message: description,
                                      preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Criar", style: .default) { _ in
            completion?(.host)
        }
        
        let action2 = UIAlertAction(title: "Ingressar", style: .default) { _ in
            completion?(.guest)
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        
        return alert
    }
    
    /// Creates a text field alert with the given information.
    ///
    /// - Parameter title: Alert's title.
    /// - Parameter description: Alert's description.
    /// - Parameter completion: Alert's completion closure, that will be executed when the user dismisses the alert.
    /// - Returns: Text field customized `UIAlertController`.
    static func createTextFieldAlert(title: String,
                                     description: String,
                                     completion: ((String) -> Void)? = nil) -> UIAlertController {
        
        let alert = UIAlertController(title: title,
                                      message: description,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Confirmar", style: .default) { _ in
            if let textField = alert.textFields?.first,
               let text = textField.text {
                completion?(text)
            }
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Nome"
        }
        
        alert.addAction(action)
        
        return alert
    }
}
