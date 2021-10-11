//
//  AuditView.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 11/10/21.
//

import Foundation
import UIKit

final class AuditView: UIView {
    
    // MARK: - Internal properties
    
    var didSelectBlockAtIndex: ((Int) -> Void)?
    
    // MARK: - Private properties
    
    /// The current `Blockchain` model.
    private var blockchain: Blockchain
    
    /// Table view with connected peers data.
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    // MARK: - Initializers
    
    /// Initializes a `BlockchainDetailView`.
    ///
    /// - Parameter blockchain: The current `Blockchain` model.
    init(blockchain: Blockchain) {
        self.blockchain = blockchain
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
        
        blockchain.blocks = blockchain.blocks.reversed()
        
        backgroundColor = .secondarySystemBackground
        
        tableView.register(BlockCell.self, forCellReuseIdentifier: "blockCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource and UITableViewDelegate
/// The `UITableViewDataSource` protocol is responsible for managing the presentation of the table view data
/// and the `UITableViewDelegate` protocol is responsible fot managing table view's interface and actions.
extension AuditView: UITableViewDataSource, UITableViewDelegate {
    
    /// Sets the number of rows in section as the connected peers in the local network session plus 2, representing
    /// the usr itself and the searching feedback cell.
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        return blockchain.blocks.count
    }
    
    /// Configures the table view's cells. It creates `UITableViewCell` with `.default` style and customizes the interface
    /// according to the index path. If is the fist row, creates a cell with the user name. If is the last row, creates a cell with
    /// searching message. Else, creates cells with the connected peers names.
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "blockCell",
                                                       for: indexPath) as? BlockCell else {
            return UITableViewCell()
        }
        
        cell.setup(with: blockchain.blocks[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        didSelectBlockAtIndex?(indexPath.row)
    }
}
