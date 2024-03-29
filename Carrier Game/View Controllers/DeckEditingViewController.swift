//
//  DeckEditingViewController.swift
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
    moduleRotate,
    moduleSave,
    moduleCancel,
    rootOverlays,
    overlaysZAccess,
    overlaysBounds,
    rootDeck,
    deckPrevious,
    deckNext,
    deckValidate,
    deckNew
}

// EDITIGN TODO: Was in the middle of add deck logic when did simulation vs. editing refactor.

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

class DeckEditingViewController: Deck2DViewController<BaseDeck2DScene>, ModuleListViewControllerDelegate, SlidingMenuToolbarViewControllerDelegate {
    
    private enum PanMode { case none, active(ModuleEntity, CGPoint) }
    
    private enum EditMode: Equatable { case none, active(ModuleEntity, UndoManager) }
    
    // MARK: - Initialization
    
    init(ship: ShipBlueprint) {
        super.init(scene: BaseDeck2DScene(ship: ship, size: CGSize(width: 50, height: 50)), ship: ship)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    private var panMode: PanMode = .none
    
    private var editMode: EditMode = .none {
        didSet {
            guard editMode != oldValue else { return }
            // If new mode is active then toggle editing overlay on associated node component
            if case .active(let entity, _) = editMode {
                entity.mainNodeComponent.showEditingOverlay = true
//                if scene.enableSimulation { toggleSimulation() }
            }
            // If old value was also active it must have been a different module. So end editing.
            if case .active(let entity, _) = oldValue {
                entity.mainNodeComponent.showEditingOverlay = false
            }
        }
    }
    
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
    
    private var overlayNodes = [SKNode]()
    
    private lazy var context: NSManagedObjectContext = {
        // TODO: Create a new main context with viewContext as parent? Or store?
        return NSPersistentContainer.model.viewContext
    }()
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add toolbar control
        addChild(slidingMenuToolbarController) { toolbarView in
            // Configure and add to view
            toolbarView.translatesAutoresizingMaskIntoConstraints = false
            toolbarView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
            self.view.addSubview(toolbarView)
            // Constrain
            NSLayoutConstraint.constraintsPinningView(toolbarView, axis: .horizontal).activate()
            toolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
            // - Height constraint based on preferredContentSize
            slidingMenuToolbarHeightConstraint.activate()
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
        // - Rotate
        let rotateModule = MenuTreeItem(title: "Rotate", identifier: MenuItemID.moduleRotate)
        rotateModule.persistentSelection = false
        rootModule.items.append(rotateModule)
        // - Save
        let saveModule = MenuTreeItem(title: "Save", identifier: MenuItemID.moduleSave)
        saveModule.persistentSelection = false
        rootModule.items.append(saveModule)
        // - Cancel
        let cancelModule = MenuTreeItem(title: "Cancel", identifier: MenuItemID.moduleCancel)
        cancelModule.persistentSelection = false
        rootModule.items.append(cancelModule)
        
        // OVERLAYS
        let rootOverlays = MenuTreeItem(title: "Overlays", identifier: MenuItemID.rootOverlays)
        rootItems.append(rootOverlays)
        // - Lifts
        rootOverlays.items.append(MenuTreeItem(title: "Lifts", identifier: MenuItemID.overlaysZAccess))
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
        let deckValidate = MenuTreeItem(title: "Validate", identifier: MenuItemID.deckValidate)
        deckValidate.persistentSelection = false
        rootDeck.items.append(deckValidate)
        // - New
        let deckNew = MenuTreeItem(title: "New", identifier: MenuItemID.deckNew)
        deckNew.persistentSelection = false
        rootDeck.items.append(deckNew)
        
        // Return constructed tree
        return SlidingMenuTree(rootItems: rootItems)
    }
    
    private func makeUndoManager() -> UndoManager {
        let undoManager = UndoManager()
        undoManager.groupsByEvent = false
        undoManager.beginUndoGrouping()
        return undoManager
    }
    
    private func addZAccessOverlays() {
        let overlay = ZAccessOverlayNode(ship: ship)
        overlay.deckIndex = shipEntity.deckEntities.firstIndex(of: scene.visibleDeck)!
        scene.addChild(overlay)
        overlayNodes.append(overlay)
    }
    
    private func rotateModule() {
        guard case .active(let entity, _) = editMode else {
            assertionFailure("Invalid editMode for rotation.")
            return
        }
        // Increment by 1 or reset if already at 3/4 rotation
        entity.placement.rotation = GridRotation(rawValue: entity.placement.rotation.rawValue + 1) ?? .none
    }
    
    private func cancelEditingModule() {
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
    
    private func saveEditingModule() {
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
            ship.redrawGraph()
            // End editing
            editMode = .none
        } catch {
            logger.logError("Error saving newly placed module: \(error)")
        }
        
        // TODO: NEED TO CHANGE THIS.
        // - Implemented logic to update all existing instances- this is certainly not going to be the final logic. Need an update path or revisions model?
        for instance in ship.instances {
            // Get deck instance to place on
            // NOTE: Won't exist when not updating all instances
            let deck = instance.decks.first(where: { $0.blueprint == scene.visibleDeck.blueprint })!
            // Create new module instance and add to deck
            let moduleInstance = ModuleInstance.insertNew(into: context, using: module.placement)
            deck.modules.insert(moduleInstance)
        }
        do {
            try context.save()
        } catch {
            print("&& CAUGHT ERROR SAVING INSTANCES: \(error)")
        }
    }
    
    private func addNewDeck() {
        // Make deck blueprint
        let deckPosition = ship.orderedDecks.last!.position + 1
        let deck = DeckBlueprint.insertNew(into: context, on: ship, at: deckPosition)
        deck.name = "New Deck"
        // Add to ship entity
        let entity = shipEntity.addDeckEntity(for: deck)
        // Display
        scene.displayDeck(entity: entity)
        // Save insertion
        do {
            try NSPersistentContainer.model.viewContext.save()
            logger.logInfo("Saved new deck at position: \(deck.position).")
        } catch {
            logger.logError("Error saving new deck: \(deck)")
            // TODO: ROLL BACK?
        }
        
        // TODO: NEED TO CHANGE THIS.
        // - Implemented logic to update all existing instances- this is certainly not going to be the final logic. Need an update path or revisions model?
        for instance in ship.instances {
            let deckInstance = DeckInstance.insertNew(into: context, using: deck)
            instance.decks.insert(deckInstance)
        }
        do {
            try context.save()
        } catch {
            print("&& CAUGHT ERROR SAVING INSTANCES: \(error)")
        }
    }
    
    // MARK: Actions
    
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
    
    override func recognizedTap(_ recognizer: UITapGestureRecognizer) {
        super.recognizedTap(recognizer)
        // Get nodes at tap
        let nodes = scene.nodes(atViewLocation: recognizer.location(in: view))
        guard !nodes.isEmpty else { return }
        // Find nodes representing something we want to log
        for node in nodes {
            guard let name = SKNode.Name(rawValue: node.name ?? "") else { continue }
            switch name {
            case .module:
                guard let entity = scene.visibleDeck.moduleEntities.first(where: { $0.mainNodeComponent.node == node }) else { continue }
                logger.logDebug("Tapped module: \(entity.blueprint.identifier).")
            default:
                break
            }
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
        // Create module placement on deck blueprint
        let modulePlacement = scene.visibleDeck.blueprint.placeModule(module, at: CDPoint2(x: 0, y: 0))
        // Add new entity to deck
        let moduleEntity = scene.visibleDeck.addModuleEntity(for: modulePlacement)
        
        // Make an undo manager
        let undoManager = makeUndoManager()
        // Set mode to editing
        editMode = .active(moduleEntity, undoManager)
        
        // Register undo logic
        undoManager.registerUndo(withTarget: moduleEntity) { [unowned self] (moduleEntity) in
            // Remove entity from deck
            self.scene.visibleDeck.removeModuleEntity(moduleEntity)
            // Remove CoreData changes
            self.scene.visibleDeck.blueprint.modulePlacements.remove(modulePlacement)
            self.context.delete(modulePlacement)
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
            guard case .none = editMode else { return false }
            let listController = ModuleListViewController()
            listController.delegate = self
            present(listController, animated: true, completion: nil)
        case .moduleRotate:
            guard case .active = editMode else { return false }
            rotateModule()
        case .moduleSave:
            guard case .active = editMode else { return false }
            saveEditingModule()
        case .moduleCancel:
            guard case .active = editMode else { return false }
            cancelEditingModule()
        case .deckNext:
            scene.displayDeck(entity: nextDeck())
        case .deckPrevious:
            scene.displayDeck(entity: previousDeck())
        case .deckValidate:
            // Overlapping points would already be validated, so only validate open bounds
            let openPoints = scene.visibleDeck.blueprint.findOpenPoints()
            scene.visibleDeck.flashInvalidPoints(openPoints)
        case .deckNew:
            addNewDeck()
            slidingMenuToolbarController.deselectItem(withIdentifier: MenuItemID.rootDeck.rawValue)
        case .overlaysZAccess:
            addZAccessOverlays()
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
        // Determine what to do with deselection
        switch MenuItemID(rawValue: item.identifier)! {
        case .overlaysZAccess:
            guard let overlayIndex = overlayNodes.firstIndex(where: { $0 is ZAccessOverlayNode }) else {
                assertionFailure("ZAccess overlay node not found in existing overlay nodes.")
                return
            }
            // Remove overlay
            let overlay = overlayNodes[overlayIndex] as! ZAccessOverlayNode
            overlayNodes.remove(at: overlayIndex)
            overlay.removeFromParent()
        default:
            break
        }
    }
    
    // MARK: UIGestureRecognizer Delegate Implementation
    
    // TODO: NO LONGER WORKING?
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow long press and pan to be recognized simultaneously
        return gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UILongPressGestureRecognizer
    }
}
