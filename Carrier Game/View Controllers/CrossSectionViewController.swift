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
    
    private enum PanMode { case none, active(SKNode, CGPoint) }
    
    // MARK: - Initialization
    
    // MARK: - Properties
    
    private var panMode: PanMode = .none
    private var editingNode: SKNode?
    
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
                // Activate panning. Assign editing node and editing node's *position in view* to enum
                panMode = .active(editingNode, scene.convertPoint(toView: editingNode.position))
            }
        case .ended:
            panMode = .none
            return
        default:
            break
        }
        // If not panning delegate to super's behavior
        guard case .active(let node, var originalPosition) = panMode else {
            super.recognizedPan(recognizer)
            return
        }
        // Add *total* translation to original position for point that it would be at in view
        originalPosition += recognizer.translation(in: view)
        // Convert this position to a scene coord in our grid coords
        let newGridPos = GridPoint3(scene.convertPoint(fromView: originalPosition), 0)
        // Compare current position and new position in GridPoints. If they're different assign new position from GridPoints.
        guard GridPoint3(node.position, 0) != newGridPos else { return }
        node.position = CGPoint(x: newGridPos.x, y: newGridPos.y)
    }
    
    // MARK: ModuleListViewController Delegate
    
    func moduleListViewController(_: ModuleListViewController, selectedModule module: ModuleBlueprint) {
        dismiss(animated: true, completion: nil)
        print("&& SELECTED MODULE: \(module)")
    }
}
