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

private enum MenuItemID: String {
    case rootModule,
    moduleAdd,
    rootOverlays,
    overlaysLifts,
    overlaysBounds,
    rootDeck,
    deckPrevious,
    deckNext,
    deckValidate
}

// TODO: MAIN- Flesh out menu options. Continue improving sliding menu delegate. Eventually go to adding a new deck to blueprint + required overlays
// TODO: MAKE MORE ROBUST AND DELEGATE?

class MenuTreeItem {
    
    convenience init<T>(title: String, identifier: T) where T: RawRepresentable, T.RawValue == String {
        self.init(title: title, identifier: identifier.rawValue)
    }
    
    convenience init(title: String, identifier: String) {
        self.init(item: SlidingMenuToolbarViewController.MenuItem(type: .text(title), identifier: identifier))
    }
    
    init(item: SlidingMenuToolbarViewController.MenuItem) {
        self.menuItem = item
    }
    
    let menuItem: SlidingMenuToolbarViewController.MenuItem
    var items = [MenuTreeItem]()
    var persistentSelection = true
    
    var allItems: [MenuTreeItem] {
        return [self] + items.flatMap { $0.allItems }
    }
}

class SlidingMenuTree {
    
    init(rootItems: [MenuTreeItem]) {
        self.rootItems = rootItems
    }
    
    var rootItems: [MenuTreeItem]
    
    var allItems: [MenuTreeItem] {
        return rootItems.flatMap { $0.allItems }
    }
    
    func item(withIdentifier identifier: String) -> MenuTreeItem? {
        return allItems.first(where: { $0.menuItem.identifier == identifier })
    }
}

class CrossSectionViewController: Deck2DViewController, ModuleListViewControllerDelegate, SlidingMenuToolbarViewControllerDelegate {
    
    private enum PanMode { case none, active(ModuleEntity, CGPoint) }
    
    private enum EditMode: Equatable { case none, active(ModuleEntity, UndoManager) }
    
    // MARK: - Initialization
    
    // MARK: - Properties
    
    private var panMode: PanMode = .none
    
    private var editMode: EditMode = .none {
        didSet {
            guard editMode != oldValue else { return }
            // If new mode is active then toggle editing overlay on associated node component
            if case .active(let entity, _) = editMode {
                entity.mainNodeComponent.showEditingOverlay = true
                if scene.enableSimulation { toggleSimulation() }
            }
            // If old value was also active it must have been a different module. So end editing.
            if case .active(let entity, _) = oldValue {
                entity.mainNodeComponent.showEditingOverlay = false
            }
        }
    }
    
    private lazy var context: NSManagedObjectContext = {
        // TODO: Create a new main context with viewContext as parent? Or store?
        return NSPersistentContainer.model.viewContext
    }()
    
    private lazy var slidingMenuToolbarController: SlidingMenuToolbarViewController = {
        let controller = SlidingMenuToolbarViewController()
        controller.delegate = self
        return controller
    }()
    
    private lazy var menuTree: SlidingMenuTree = {
        return makeMenuTree()
    }()
    
    private lazy var slidingMenuToolbarHeightConstraint: NSLayoutConstraint = {
        return slidingMenuToolbarController.view.heightAnchor.constraint(equalToConstant: 0).withPriority(.defaultHigh)
    }()
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Disable simulation
        scene.enableSimulation = false
        // Add toolbar control
        addChild(slidingMenuToolbarController) { (toolbarView, completed) in
            // Configure and add to view
            toolbarView.translatesAutoresizingMaskIntoConstraints = false
            toolbarView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
            self.view.addSubview(toolbarView)
            // Constrain
            NSLayoutConstraint.constraintsPinningView(toolbarView, axis: .horizontal).activate()
            toolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
            // - Height constraint based on preferredContentSize
            slidingMenuToolbarHeightConstraint.activate()
            completed()
        }
    }

    override func setupRecognizers() {
        super.setupRecognizers()
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(recognizedLongPress(_:)))
        view.addGestureRecognizer(longPressRecognizer)
        longPressRecognizer.delegate = self
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        guard let container = container as? UIViewController, container == slidingMenuToolbarController else { return }
        slidingMenuToolbarHeightConstraint.constant = container.preferredContentSize.height
    }
    
    private func makeMenuTree() -> SlidingMenuTree {
        var rootItems = [MenuTreeItem]()
        
        // MODULE
        let rootModule = MenuTreeItem(title: "Module", identifier: MenuItemID.rootModule)
        rootItems.append(rootModule)
        // - Add
        let addModule = MenuTreeItem(title: "Add", identifier: MenuItemID.moduleAdd)
        addModule.persistentSelection = false
        rootModule.items.append(addModule)
        
        // OVERLAYS
        let rootOverlays = MenuTreeItem(title: "Overlays", identifier: MenuItemID.rootOverlays)
        rootItems.append(rootOverlays)
        // - Lifts
        rootOverlays.items.append(MenuTreeItem(title: "Lifts", identifier: MenuItemID.overlaysLifts))
        // - Bounds
        rootOverlays.items.append(MenuTreeItem(title: "Bounds", identifier: MenuItemID.overlaysBounds))
        
        // DECK
        let rootDeck = MenuTreeItem(title: "Deck", identifier: MenuItemID.rootDeck)
        rootItems.append(rootDeck)
        // - Previous
        let deckPrevious = MenuTreeItem(title: "Previous", identifier: MenuItemID.deckPrevious)
        deckPrevious.persistentSelection = false
        rootDeck.items.append(deckPrevious)
        // - Next
        let deckNext = MenuTreeItem(title: "Next", identifier: MenuItemID.deckNext)
        deckNext.persistentSelection = false
        rootDeck.items.append(deckNext)
        // - Validate
        rootDeck.items.append(MenuTreeItem(title: "Validate", identifier: MenuItemID.deckValidate))
        
        // Return constructed tree
        return SlidingMenuTree(rootItems: rootItems)
    }
    
    private func makeUndoManager() -> UndoManager {
        let undoManager = UndoManager()
        undoManager.groupsByEvent = false
        undoManager.beginUndoGrouping()
        return undoManager
    }
    
    // MARK: Actions
    
    @objc private func toggleSimulation() {
        // If simulation disabled (meaning the toggle will reenable) then find crewmen in invalid locations and move them to a random, valid location
        if !scene.enableSimulation {
            let gridPositions: [GridPoint3] = ship.blueprint.graph.gridNodes?.map({ $0.position }) ?? []
            for crewman in shipEntity.crewmanEntities {
                // Check whether crewman's current position is still valid
                guard !gridPositions.contains(GridPoint3(crewman.instance.position)) else { continue }
                // Find a random node
                let position = gridPositions.randomElement()!
                // Assign crewman's position here
                crewman.movementComponent.setPosition(position)
            }
        }
        // Reenable simulation and re-configure toolbar
        scene.enableSimulation.toggle()
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
        guard case .active(let module, _) = editMode else {
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
            logger.logInfo("Successfully saved new module: \(module.blueprint.identifier)")
            // Ask ship blueprint to redraw its grid graph
            ship.blueprint.redrawGraph()
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
            assertionFailure("Could not find entity with module node on current deck. This should not happen.")
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
            let sceneLocation = scene.convertPoint(fromView: recognizer.location(in: view))
            if case .active(let entity, _) = editMode, scene.nodes(at: sceneLocation).contains(entity.mainNodeComponent.node) {
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
        // Place module instance on deck
        let moduleInstance = scene.visibleDeck.instance.placeModule(module, at: CDPoint2(x: 0, y: 0))
        // Create module entity
        let moduleEntity = ModuleEntity(placement: moduleInstance.placement)
        // Add to deck
        scene.visibleDeck.moduleEntities.append(moduleEntity)
        // Add to scene
        scene.addChild(moduleEntity.mainNodeComponent.node)
        
        // Make an undo manager
        let undoManager = makeUndoManager()
        // Set mode to editing
        editMode = .active(moduleEntity, undoManager)
        
        // Register undo logic
        undoManager.registerUndo(withTarget: moduleEntity) { [unowned self] (moduleEntity) in
            // Remove added entities and node
            self.scene.visibleDeck.moduleEntities.removeAll(where: { $0 == moduleEntity })
            moduleEntity.mainNodeComponent.node.removeFromParent()
            // Remove CoreData changes
            self.scene.visibleDeck.instance.modules.remove(moduleInstance)
            self.scene.visibleDeck.blueprint.modulePlacements.remove(moduleInstance.placement)
            self.context.delete(moduleInstance.placement)
            self.context.delete(moduleInstance)
            // Save
            do {
                try self.context.save()
            } catch {
                self.logger.logError("Error saving context during undo: \(error)")
            }
        }
    }
    
    // MARK: SlidingMenuToolbarViewController Delegate Implementation
    
    func slidingMenuViewController(_: SlidingMenuToolbarViewController, shouldSelectTappedItem item: SlidingMenuToolbarViewController.MenuItem) -> Bool {
        // Determine what to do with selection
        switch MenuItemID(rawValue: item.identifier)! {
        case .moduleAdd:
            let listController = ModuleListViewController()
            listController.delegate = self
            present(listController, animated: true, completion: nil)
        case .deckNext:
            scene.visibleDeck = nextDeck()
        case .deckPrevious:
            scene.visibleDeck = previousDeck()
        case .deckValidate:
            // Overlapping points would already be validated, so only validate open bounds
            let openPoints = scene.visibleDeck.blueprint.findOpenPoints()
            scene.visibleDeck.flashInvalidPoints(openPoints)
        default:
            break
        }
        return menuTree.item(withIdentifier: item.identifier)!.persistentSelection
    }
    
    func slidingMenuViewController(_ controller: SlidingMenuToolbarViewController, itemsForSelectedItem item: SlidingMenuToolbarViewController.MenuItem?) -> [SlidingMenuToolbarViewController.MenuItem]? {
        // If no selected item then this is root items
        guard let item = item else { return menuTree.rootItems.map { $0.menuItem } }
        // Provide any child items
        return menuTree.item(withIdentifier: item.identifier)!.items.map { $0.menuItem }
    }
    
    func slidingMenuViewController(_: SlidingMenuToolbarViewController, deselectedItem item: SlidingMenuToolbarViewController.MenuItem) {
        print("&& DESELECTED ITEM: \(item)")
    }
    
    // MARK: UIGestureRecognizer Delegate Implementation
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow long press and pan to be recognized simultaneously
        return gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UILongPressGestureRecognizer
    }
}
