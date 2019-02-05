//
//  CrossSectionViewController.swift
//  Carrier Game
//
//  Created by Sean G Young on 10/17/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit
import SpriteKit
import CoreData
import GameplayKit
import SGYSwiftUtility

class CrossSectionViewController: Deck2DViewController, ModuleListViewControllerDelegate {
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addModuleButton()
    }
    
    private func addModuleButton() {
        // - Module list
        let moduleButton = UIButton()
        moduleButton.setTitle("Add Module", for: [])
        moduleButton.setTitleColor(.blue, for: [])
        moduleButton.addTarget(self, action: #selector(showModuleList), for: .touchUpInside)
        optionsStack.addArrangedSubview(moduleButton)
    }
    
    @objc private func showModuleList() {
        let listController = ModuleListViewController()
        listController.delegate = self
        present(listController, animated: true, completion: nil)
    }
    
    // MARK: ModuleListViewController Delegate
    
    func moduleListViewController(_: ModuleListViewController, selectedModule module: ModuleBlueprint) {
        dismiss(animated: true, completion: nil)
        print("&& SELECTED MODULE: \(module)")
    }
}
