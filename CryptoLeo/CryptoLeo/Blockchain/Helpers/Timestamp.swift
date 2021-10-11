//
//  Timestamp.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 04/10/21.
//

import Foundation

/// Current date and time.
struct Timestamp {
    
    /// Creates a string with the current date.
    /// - Returns: String with current date, formatted as `dd/MM/yyyy HH:mm:ss`.
    static func string() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy (HH:mm:ss)"
        return dateFormatter.string(from: date)
    }
}
