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
    
    private enum PanMode { case none, active(SKNode, ModulePlacement, CGPoint) }
    
    private enum EditMode { case none, active(SKNode, ModulePlacement) }
    
    // MARK: - Initialization
    
    // MARK: - Properties
    
    private var panMode: PanMode = .none
    
    private var editMode: EditMode = .none {
        didSet { configureToolbar() }
    }
    
    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    private lazy var context: NSManagedObjectContext = {
        // TODO: Create a new main context with viewContext as parent? Or store?
        return NSPersistentContainer.model.viewContext
    }()
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add toolbar
        view.addSubview(toolbar)
        NSLayoutConstraint.constraintsPinningView(toolbar, axis: .horizontal).activate()
        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
        // Show initial toolbar config
        configureToolbar()
        
        // TODO: TEMPORARY. SEEMS ODD TO JUST "PAUSE" EVENTS WHILE EDITING.
        sceneController.autoManagePause = false
        scene.isPaused = true
    }
    
    private func configureToolbar() {
        var items = [UIBarButtonItem]()
        // Configure based on edit mode
        switch editMode {
        case .none:
            // Add module
            items.append(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showModuleList)))
        case .active:
            // Rotate module
            items.append(UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(rotateModule)))
            // Spacer
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            // End editing
            items.append(UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(endEditingModule)))
        }
        // Add
        toolbar.setItems(items, animated: true)
    }
    
    // MARK: Actions
    
    @objc private func showModuleList() {
        let listController = ModuleListViewController()
        listController.delegate = self
        present(listController, animated: true, completion: nil)
    }
    
    @objc private func rotateModule() {
        guard case .active(_, let placement) = editMode else {
            assertionFailure("Invalid mode for rotation.")
            return
        }
        // Increment by 1 or reset if already at 3/4 rotation
        placement.rotation = GridRotation(rawValue: placement.rotation.rawValue + 1) ?? .none
        
//        if let newRotation = GridRotation(rawValue: placement.rotation.rawValue + 1) {
//            placement.rotation = newRotation
//        } else {
//            // Otherwise was already at 3/4 so reset
//            placement.rotation = .none
//        }
    }
    
//    @objc private func rotateModule() {
//        guard case .active(let node, _) = editMode else {
//            assertionFailure("Invalid mode for rotation.")
//            return
//        }
//        // Determine number of current rotations (cannot compare exact numbers due to CGFloat's imprecision)
//        let rotations = floor(node.zRotation / (CGFloat.pi / 2))
//        switch rotations {
//        case 3: node.zRotation = 0
//        default: node.zRotation += CGFloat.pi / 2.0
//        }
//    }
    
    @objc private func endEditingModule() {
        guard case let .active(node, _) = editMode else {
            logger.logError("Asked to end editing module when editMode did not match. editMode: \(editMode)")
            return
        }
        // Remove node
        node.removeFromParent()
        // End editing
        editMode = .none
    }
    
    override func recognizedPan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            // Determine if initial pan started on editing node
            let scenePoint = scene.convertPoint(fromView: recognizer.location(in: view))
            if case .active(let editingNode, let placement) = editMode, scene.nodes(at: scenePoint).contains(editingNode) {
                // Activate panning. Assign editing node and editing node's *position in view* to enum
                panMode = .active(editingNode, placement, scene.convertPoint(toView: editingNode.position))
            }
        case .ended:
            panMode = .none
            return
        default:
            break
        }
        // If not panning delegate to super's behavior
        guard case .active(let node, let placement, var originalPosition) = panMode else {
            super.recognizedPan(recognizer)
            return
        }
        // Add *total* translation to original position for point that it would be at in view
        originalPosition += recognizer.translation(in: view)
        // Convert this position to a scene coord in our grid coords
        let newGridPos = GridPoint3(scene.convertPoint(fromView: originalPosition), 0)
        // Compare current position and new position in GridPoints. If they're different assign new position from GridPoints.
        guard GridPoint3(node.position, 0) != newGridPos else { return }
        placement.origin = CDPoint2(x: newGridPos.x, y: newGridPos.y)
    }
    
    // MARK: ModuleListViewController Delegate
    
    func moduleListViewController(_: ModuleListViewController, selectedModule module: ModuleBlueprint) {
        dismiss(animated: true, completion: nil)
        // Assigned deck is required
        guard let (deck, _) = currentDeck else {
            assertionFailure("Module selected without a current deck.")
            return
        }
        // Create a new module placement
        let modulePlacement = ModulePlacement.insertNew(into: context)
        modulePlacement.origin = CDPoint2(x: 0, y: 0)
        modulePlacement.rotation = .none
        modulePlacement.blueprint = module
        modulePlacement.deck = deck.blueprint
        // Create a module entity
        let moduleEntity = ModuleEntity(placement: modulePlacement)
        moduleEntity.mainNodeComponent.showEditingOverlay = true
        // TODO: ADD TO SOME ENTITIES COLLECTION SOMEWHERE?
        
        // TODO: TESTING WITH BASIC NODE (NOT EDITING)
        let moduleNode = moduleEntity.mainNodeComponent.node
        scene.addChild(moduleNode)
        
        
        // Set mode to editing
        editMode = .active(moduleNode, modulePlacement)
        
        
        print("&& SELECTED MODULE: \(module)")
    }
}
