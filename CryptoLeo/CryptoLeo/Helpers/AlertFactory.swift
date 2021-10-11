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
    
    /// Presents a default alert with the given information.
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
}
