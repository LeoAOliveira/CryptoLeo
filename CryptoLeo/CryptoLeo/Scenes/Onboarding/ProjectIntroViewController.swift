//
//  ProjectIntroViewController.swift
//  CryptoLeo
//
//  Created by Leonardo Oliveira on 13/10/21.
//

import Foundation
import UIKit

final class ProjectIntroViewController: UIViewController {
    
    let containerView: IntroView
    
    init() {
        containerView = IntroView()
        super.init(nibName: nil, bundle: nil)
        bindViewEvents()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = containerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.text = CryptoLeoStrings.projectIntro
        containerView.buttonTitle = CryptoLeoStrings.insertName
    }
    
    private func bindViewEvents() {
        
        containerView.didTapButton = { [weak self] in
            self?.presentTextFieldAlert()
        }
    }
    
    private func presentTextFieldAlert() {
        
        let title = CryptoLeoStrings.name
        let description = CryptoLeoStrings.nameDescription
        
        let alert = AlertFactory.createTextFieldAlert(title: title,
                                                      description: description) { [weak self] name in
            self?.pushToAppIntroViewController(name: name)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func pushToAppIntroViewController(name: String) {
        
        let controller = AppIntroViewController(name: name)
        navigationController?.pushViewController(controller, animated: true)
    }
}
