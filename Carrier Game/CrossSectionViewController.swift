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

class CrossSectionViewController: UIViewController, ModuleListViewControllerDelegate {
    
    // MARK: - Initialization
    
    init(ship: ShipInstance) {
        self.ship = ship
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let ship: ShipInstance
    
    private lazy var logger = Logger(source: type(of: self))
    
    private var skView: SKView {
        return view as! SKView
    }
    
    private lazy var shipEntity: ShipEntity = {
        return ShipEntity(ship: ship)
    }()
    
    private lazy var scene: DeckScene = {
        let scene = DeckScene(size: CGSize(width: 50, height: 50))
        scene.scaleMode = .aspectFit
        // Add camera
        scene.addChild(camera)
        scene.camera = camera
        return scene
    }()
    
    private lazy var camera: SKCameraNode = {
        let camera = SKCameraNode()
        return camera
    }()
    
    private lazy var deckButton: UIButton = {
        let button = UIButton(translatesAutoresizingMask: false)
        button.setTitleColor(.blue, for: [])
        button.addTarget(self, action: #selector(toggleDeck), for: .touchUpInside)
        return button
    }()
    
    private var sceneController: SceneController?
    
    private var currentDeck: (entity: DeckEntity, node: SKNode)? {
        didSet {
            deckButton.setTitle("Next Deck: \(nextDeck().instance.placement.position)", for: [])
        }
    }
    
    private var lastTranslation: CGPoint = .zero
    
    // MARK: - Methods
    
    override func loadView() {
        view = SKView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Assign scene controller
        sceneController = SceneController(scene: scene)
        // Present scene
        skView.presentScene(scene)
        // Setup camera
        setupCamera()
        // Setup ship
        setupShip()
        // Setup recognizers
        setupRecognizers()
        // Setup button stack
        setupButtonStack()
        
        // View first deck
        displayDeck(entity: shipEntity.deckEntities.first!)

    }
    
    private func displayDeck(entity: DeckEntity) {
        logger.logInfo("Displaying deck: \(entity.instance.placement.position).")
        // If another deck's node is currently displayed then remove
        currentDeck?.node.removeFromParent()
        // Add new deck's texture node
        let newNode = entity.makeNode()
        scene.addChild(newNode)
        // Update all crewman's movement component
        for crewman in shipEntity.crewmanEntities {
            let component = crewman.component(ofType: MovementComponent2D.self)!
            component.visibleVertical = GridPoint(entity.instance.placement.position)
        }
        // Assign new deck info
        currentDeck = (entity: entity, node: newNode)
    }
    
    private func setupCamera() {
        // TODO: ALL TEMPORARY
        camera.xScale = 0.3
        camera.yScale = 0.3
        camera.position = CGPoint(x: 5, y: 0)
    }
    
    private func setupShip() {
        // Add ship entity to scene
        scene.entities.append(shipEntity)
        scene.entities.append(contentsOf: shipEntity.allEntities)
        // Setup crewmen for this scene
        for crewman in shipEntity.crewmanEntities {
            // Add a 2D movement component
            crewman.addComponent(MovementComponent2D())
            // Add node to scene
            // NOTE: crewman nodes are always added regardless of the deck they're on because they hide/unhide themselves based on this fact. Keeping the nodes on scene helps time their movement on invisible decks.
            scene.addChild(crewman.rootNode)
            // Raise z on crewman node
            crewman.rootNode.zPosition = 100
        }
    }
    
    private func setupButtonStack() {
        // Add stack
        let stack = UIStackView(translatesAutoresizingMask: false)
        stack.axis = .vertical
        stack.spacing = NSLayoutConstraint.systemSiblingSpacing
        view.addSubview(stack)
        stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).activate()
        stack.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).activate()
        // Add buttons
        // - Deck toggle
        stack.addArrangedSubview(deckButton)
        // - Module list
        let moduleButton = UIButton()
        moduleButton.setTitle("Add Module", for: [])
        moduleButton.setTitleColor(.blue, for: [])
        moduleButton.addTarget(self, action: #selector(showModuleList), for: .touchUpInside)
        stack.addArrangedSubview(moduleButton)
    }
    
    private func setupRecognizers() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(recognizedTap(_:))))
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(recognizedPan(_:))))
    }
    
    private func nextDeck() -> DeckEntity {
        let deck = currentDeck!.entity
        if shipEntity.deckEntities.last == deck {
            return shipEntity.deckEntities.first!
        } else {
            return shipEntity.deckEntities[Int(deck.instance.placement.position + 1)]
        }
    }
    
    // MARK: Actions
    
    @objc private func toggleDeck() {
        displayDeck(entity: nextDeck())
    }
    
    @objc private func showModuleList() {
        let listController = ModuleListViewController()
        listController.delegate = self
        present(listController, animated: true, completion: nil)
    }
    
    @objc private func recognizedTap(_ recognizer: UITapGestureRecognizer) {
        // Convert tap to scene coord system
        let point = scene.convertPoint(fromView: recognizer.location(in: view))
        // Get nodes
        let nodes = scene.nodes(at: point)
        // TAP LOGIC
        // Print point as grid
        
        let np = scene.convert(point, to: currentDeck!.node)
        
        logger.logInfo("Tapped grid point: \(GridPoint(point.x)), \(GridPoint(point.y)). NEW: \(np). POINT: \(point)")
        // Find associated crewman
        let crewmen = shipEntity.crewmanEntities.filter({ nodes.contains($0.rootNode) })
        for crewman in crewmen {
            // Add or remove from stat report on scene
            if let index = scene.reporter.providers.firstIndex(where: { $0 as? CrewmanEntity == crewman }) {
                scene.reporter.providers.remove(at: index)
            } else {
                scene.reporter.providers.append(crewman)
            }
        }
    }
    
    @objc private func recognizedPan(_ recognizer: UIPanGestureRecognizer) {
        guard recognizer.state != .ended else {
            lastTranslation = .zero
            return
        }
        let translation = recognizer.translation(in: view)
        // Get delta by subtracting new value from current translation (still in view coord system)
        let delta = translation - lastTranslation
        // Translate camera position to view coords
        var cameraPos = scene.convertPoint(toView: camera.position)
        // Add delta and then translate back to scene coords
        cameraPos -= delta
        let newCameraPos = scene.convertPoint(fromView: cameraPos)
        // Assign new position
        camera.position = newCameraPos
        // Assign last translation
        lastTranslation = translation
    }
    
    // MARK: ModuleListViewController Delegate
    
    func moduleListViewController(_: ModuleListViewController, selectedModule module: ModuleBlueprint) {
        dismiss(animated: true, completion: nil)
        print("&& SELECTED MODULE: \(module)")
    }
}
