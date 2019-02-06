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
    
    // MARK: - Initialization
    
    // MARK: - Properties
    
    private var editingNode: SKNode?
    
    override var cameraScale: CGFloat {
        didSet {
            editingNode?.setScale(1.0 / cameraScale)
        }
    }
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addModuleButton()
        // TODO: TEMPORARY. SEEMS ODD TO JUST "PAUSE" EVENTS WHILE EDITING.
        sceneController.autoManagePause = false
        scene.isPaused = true
        
        // TODO: TESTING
        let testSprite = SKSpriteNode(color: .green, size: CGSize(width: 5, height: 5))
        testSprite.setScale(1.0 / cameraScale)
        editingNode = testSprite
        // Add to camera
        camera.addChild(testSprite)
    }
    
    override func applyCameraPan(position: CGPoint, totalDelta: CGPoint) {
        super.applyCameraPan(position: position, totalDelta: totalDelta)
        print("&& NEW CAMERA POS: \(camera.position)")
        
//        let pos = CGPoint(x: round(position.x), y: round(position.y))
//        print("&& PAN POS: \(pos)")
//
//
//        // Override and only pan by integer
//        camera.position = CGPoint(x: round(position.x), y: round(position.y))
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
