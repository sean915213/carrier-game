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
    
    private enum PanMode { case none, active(ModuleEntity, CGPoint) }
    
    private enum EditMode: Equatable { case none, active(ModuleEntity, UndoManager) }
    
    // MARK: - Initialization
    
    // MARK: - Properties
    
    private var panMode: PanMode = .none
    
    private var editMode: EditMode = .none {
        didSet {
            guard editMode != oldValue else { return }
            // Configure toolbar for mode
            configureToolbar()
            // If new mode is active then toggle editing overlay on associated node component
            if case .active(let entity, _) = editMode {
                entity.mainNodeComponent.showEditingOverlay = true
            }
            // If old value was also active it must have been a different module. So end editing.
            if case .active(let entity, _) = oldValue {
                entity.mainNodeComponent.showEditingOverlay = false
            }
        }
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
//        sceneController.autoManagePause = false
//        scene.isPaused = true
    }
    
    override func setupRecognizers() {
        super.setupRecognizers()
        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(recognizedLongPress(_:))))
    }
    
    private func configureToolbar() {
        var items = [UIBarButtonItem]()
        // Configure based on edit mode
        switch editMode {
        case .none:
            // Add module
            items.append(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showModuleList)))
            // Spacer
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            // Validate
            items.append(UIBarButtonItem(title: "Validate", style: .plain, target: self, action: #selector(validateDeck)))
        case .active:
            // Rotate module
            items.append(UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(rotateModule)))
            // Spacer
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            // Cancel placement
            items.append(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEditingModule)))
            // Save placement
            items.append(UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEditingModule)))
        }
        // Add
        toolbar.setItems(items, animated: true)
    }
    
    private func makeUndoManager() -> UndoManager {
        let undoManager = UndoManager()
        undoManager.groupsByEvent = false
        undoManager.beginUndoGrouping()
        return undoManager
    }
    
    // MARK: Actions
    
    @objc private func validateDeck() {
        // Overlapping points would already be validated, so only validate open bounds
        let openPoints = scene.visibleDeck.blueprint.findOpenPoints()
        scene.visibleDeck.flashInvalidPoints(openPoints)
    }
    
    @objc private func showModuleList() {
        let listController = ModuleListViewController()
        listController.delegate = self
        present(listController, animated: true, completion: nil)
    }
    
    @objc private func rotateModule() {
        guard case .active(let entity, _) = editMode else {
            assertionFailure("Invalid editMode for rotation.")
            return
        }
        // Increment by 1 or reset if already at 3/4 rotation
        entity.placement.rotation = GridRotation(rawValue: entity.placement.rotation.rawValue + 1) ?? .none
    }
    
    @objc private func cancelEditingModule() {
        // Get undo manager
        guard case let .active(_, undoManager) = editMode else {
            assertionFailure("Invalid editMode for cancelling.")
            return
        }
        // Perform undo
        undoManager.endUndoGrouping()
        undoManager.undo()
        // Change mode
        editMode = .none
    }
    
    @objc private func saveEditingModule() {
        // Be safe
        guard case .active = editMode else {
            assertionFailure("Invalid editMode for saving.")
            return
        }
        // Ask deck to validate overlapping points
        let overlappingPoints = scene.visibleDeck.blueprint.findOverlappingPoints()
        guard overlappingPoints.isEmpty else {
            let alert = UIAlertController(title: "Invalid Position", message: "This is not a valid position to save the module.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        do {
            // Save
            try context.save()
            logger.logInfo("Successfully saved new module.")
            // End editing
            editMode = .none
        } catch {
            logger.logError("Error saving newly placed module: \(error)")
        }
    }
    
    @objc private func recognizedLongPress(_ recognizer: UILongPressGestureRecognizer) {
        // Only matters when not editing currently
        guard case .none = editMode else { return }
        // Only looking for a module node
        guard let moduleNode = scene.nodes(atViewLocation: recognizer.location(in: view)).withName(SKNode.Name.module).first else {
            return
        }
        // Find matching module entity (which we definitely expect to find)
        guard let moduleEntity = scene.visibleDeck.moduleEntities.first(where: { $0.mainNodeComponent.node == moduleNode }) else {
            assertionFailure("Could not find entity with Module node on current deck. This should not happen.")
            return
        }
        
        // Make an undo manager to undo these changes
        let undoManager = makeUndoManager()
        // Begin editing pressed module
        editMode = .active(moduleEntity, undoManager)
        
        // Capture previous values
        let prevOrigin = moduleEntity.placement.origin
        let prevRotation = moduleEntity.placement.rotation
        // Register reversion
        undoManager.registerUndo(withTarget: moduleEntity) { entity in
            entity.placement.origin = prevOrigin
            entity.placement.rotation = prevRotation
        }
    }
    
    override func recognizedPan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            // Determine if initial pan started on editing node
            let location = recognizer.location(in: view)
            if case .active(let entity, _) = editMode, scene.nodes(atViewLocation: location).contains(entity.mainNodeComponent.node) {
                // Activate panning. Assign editing node and editing node's *position in view* to enum
                panMode = .active(entity, scene.convertPoint(toView: entity.mainNodeComponent.node.position))
            }
        case .ended:
            panMode = .none
            return
        default:
            break
        }
        // If not panning, then delegate to super's behavior
        guard case .active(let entity, var originalPosition) = panMode else {
            super.recognizedPan(recognizer)
            return
        }
        // Add *total* translation to original position for point that it would be at in view
        originalPosition += recognizer.translation(in: view)
        // Convert this position to a scene coord in our grid coords
        let newGridPos = GridPoint3(scene.convertPoint(fromView: originalPosition), 0)
        // Compare current position and new position in GridPoints. If they're different assign new position from GridPoints.
        guard GridPoint3(entity.mainNodeComponent.node.position, 0) != newGridPos else { return }
        entity.placement.origin = CDPoint2(x: newGridPos.x, y: newGridPos.y)
    }
    
    // MARK: ModuleListViewController Delegate
    
    func moduleListViewController(_: ModuleListViewController, selectedModule module: ModuleBlueprint) {
        dismiss(animated: true, completion: nil)
        // Place module on deck
        let placement = scene.visibleDeck.blueprint.placeModule(module, at: CDPoint2(x: 0, y: 0))
        // Create a module entity
        let moduleEntity = ModuleEntity(placement: placement)
        // Add to deck
        scene.visibleDeck.moduleEntities.append(moduleEntity)
        // Add to scene
        scene.activeEntities.append(moduleEntity)
        scene.addChild(moduleEntity.mainNodeComponent.node)
        
        // Make an undo manager
        let undoManager = makeUndoManager()
        // Set mode to editing
        editMode = .active(moduleEntity, undoManager)
        
        // Register undo logic
        undoManager.registerUndo(withTarget: moduleEntity) { [unowned self] (moduleEntity) in
            // Remove added entities
            self.scene.visibleDeck.moduleEntities.removeAll(where: { $0 == moduleEntity })
            self.scene.activeEntities.removeAll(where: { $0 == moduleEntity })
            // Remove node
            moduleEntity.mainNodeComponent.node.removeFromParent()
            // Remove CoreData changes
            self.scene.visibleDeck.blueprint.modulePlacements.remove(placement)
            self.context.delete(placement)
        }
    }
}
