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

// TODO: NEXT- Can now add modules and then add an overlay GKSKNodeComponent (or something) to show they're being added. But, how to create an instance without a set position from the selected ModuleBlueprint in our delegate?

class CrossSectionViewController: Deck2DViewController, ModuleListViewControllerDelegate {
    
    // MARK: - Initialization
    
    // MARK: - Properties
    
    private var editingNode: SKNode?
    
    private var panningEditNode = false
    
    // DEBUGGING
    
    
    private var originalNodePos: CGPoint = .zero
    
    // TODO: Somehow allow this class and base class to share this variable? Funnel panning through common overridable method?
    private var lastTranslation: CGPoint = .zero
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addModuleButton()
        // TODO: TEMPORARY. SEEMS ODD TO JUST "PAUSE" EVENTS WHILE EDITING.
        sceneController.autoManagePause = false
        scene.isPaused = true
        
        // TODO: TESTING
        let testSprite = SKSpriteNode(color: .green, size: CGSize(width: 5, height: 5))
//        testSprite.setScale(1.0 / cameraScale)
        editingNode = testSprite
        
        scene.addChild(testSprite)
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
    
    // MARK: Actions
    
    override func recognizedPan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            // Determine if initial pan started on editing node
            let scenePoint = scene.convertPoint(fromView: recognizer.location(in: view))
            if let editingNode = editingNode, scene.nodes(at: scenePoint).contains(editingNode) {
                // Toggle panning of edit node
                panningEditNode = true
                // DEBUGGING
                originalNodePos = editingNode.position
            }
        case .ended:
            // Reset panning variables
            lastTranslation = .zero
            panningEditNode = false
            return
        default:
            break
        }
        // If not panning or somehow no longer an edit node then perform super behavior
        guard panningEditNode, let node = editingNode else {
            super.recognizedPan(recognizer)
            return
        }
        let translation = recognizer.translation(in: view)
        // Get delta by subtracting old value from new translation
        let delta = lastTranslation - translation
        
        // - DEBUG
        
        // Translate node position to view coords
        var nodePos = scene.convertPoint(toView: originalNodePos)
        // Add delta and then translate back to scene coords
        nodePos += recognizer.translation(in: view)
        let newNodePos = scene.convertPoint(fromView: nodePos)
        
        print("&& OTHER NODE POS: \(newNodePos)")
        
        if GridPoint3(node.position, 0) != GridPoint3(newNodePos, 0) {
            // Assign new position
            node.position = CGPoint(x: GridPoint(newNodePos.x), y: GridPoint(newNodePos.y))
            
            print("&& INCREMENTED TO: \(node.position)")
        }
        
        
        // - END DEBUG
        
        
        
//        translateNode(node, byDelta: delta)
//
//        print("&& WORKING TRANSLATE POS: \(node.position)")
//
//        // Assign last translation
//        lastTranslation = translation
    }
    
    // MARK: ModuleListViewController Delegate
    
    func moduleListViewController(_: ModuleListViewController, selectedModule module: ModuleBlueprint) {
        dismiss(animated: true, completion: nil)
        print("&& SELECTED MODULE: \(module)")
    }
}
