//
//  Deck2DViewController.swift
//  Carrier Game
//
//  Created by Sean G Young on 2/4/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit
import SpriteKit
import CoreData
import GameplayKit
import SGYSwiftUtility

class Deck2DViewController: UIViewController {
    
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
    
    private(set) lazy var logger = Logger(source: type(of: self))
    
    private var skView: SKView {
        return view as! SKView
    }
    
    var scene: DeckScene {
        return sceneController.scene as! DeckScene
    }
    
    var cameraScale: CGFloat = 1.0 {
        didSet { camera.setScale(cameraScale) }
    }
    
    private(set) lazy var shipEntity: ShipEntity = {
        return ShipEntity(ship: ship)
    }()
    
    private(set) lazy var sceneController: SceneController = {
        // Create scene
        let scene = DeckScene(size: CGSize(width: 50, height: 50))
        scene.scaleMode = .aspectFit
        // Add camera
        scene.addChild(camera)
        scene.camera = camera
        // Make controller
        return SceneController(scene: scene, context: NSPersistentContainer.model.viewContext)
    }()
    
    private(set) lazy var camera: SKCameraNode = {
        let node = SKCameraNode()
        node.setScale(cameraScale)
        return node
    }()
    
    private(set) lazy var optionsStack: UIStackView = {
        // Add stack
        let stack = UIStackView(translatesAutoresizingMask: false)
        stack.axis = .vertical
        stack.spacing = NSLayoutConstraint.systemSiblingSpacing
        return stack
    }()
    
    private lazy var deckButton: UIButton = {
        let button = UIButton(translatesAutoresizingMask: false)
        button.setTitleColor(.blue, for: [])
        button.addTarget(self, action: #selector(toggleDeck), for: .touchUpInside)
        return button
    }()
    
    var currentDeck: (entity: DeckEntity, node: SKNode)? {
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
        // Present scene
        skView.presentScene(sceneController.scene)
        // Setup camera
        setupCamera()
        // Setup ship
        setupShip()
        // Setup recognizers
        setupRecognizers()
        // Setup button stack
        setupButtonStack()
        // View origin deck
        displayDeck(entity: shipEntity.deck(at: 0)!)
    }
    
    func applyCameraPan(position: CGPoint, totalDelta: CGPoint) {
        camera.position = position
    }
    
    // TODO: Still being used outside this class?
    func translateNode(_ node: SKNode, byDelta delta: CGPoint) {
        // Translate node position to view coords
        var nodePos = scene.convertPoint(toView: node.position)
        // Add delta and then translate back to scene coords
        nodePos -= delta
        let newNodePos = scene.convertPoint(fromView: nodePos)
        // Assign new position
        node.position = newNodePos
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
        camera.position = CGPoint(x: 0, y: 0)
        cameraScale = 0.3
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
        view.addSubview(optionsStack)
        optionsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).activate()
        optionsStack.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).activate()
        // Add buttons
        // - Deck toggle
        optionsStack.addArrangedSubview(deckButton)
    }
    
    private func setupRecognizers() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(recognizedTap(_:))))
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(recognizedPan(_:))))
        view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(recognizedPinch(_:))))
    }
    
    private func nextDeck() -> DeckEntity {
        let deck = currentDeck!.entity
        if shipEntity.deckEntities.last == deck {
            return shipEntity.deckEntities.first!
        } else {
            return shipEntity.deck(at: Int(deck.instance.placement.position + 1))!
        }
    }
    
    // MARK: Actions
    
    @objc private func toggleDeck() {
        displayDeck(entity: nextDeck())
    }
    
    @objc private func recognizedPinch(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .began, .changed:
            // Invert scale since we're changing the camera and not the scene being viewed
            cameraScale *= 1.0 / recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    @objc private func recognizedTap(_ recognizer: UITapGestureRecognizer) {
        // Convert tap to scene coord system
        let point = scene.convertPoint(fromView: recognizer.location(in: view))
        // TAP LOGIC
        logger.logInfo("Tapped grid point: \(GridPoint(point.x)), \(GridPoint(point.y)).")
        // Find associated crewman
        let nodes = scene.nodes(at: point)
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
    
    @objc func recognizedPan(_ recognizer: UIPanGestureRecognizer) {
        guard recognizer.state != .ended else {
            lastTranslation = .zero
            return
        }
        let translation = recognizer.translation(in: view)
        // Get delta by subtracting new value from current translation (still in view coord system)
        let delta = translation - lastTranslation
        translateNode(camera, byDelta: delta)
        // Assign last translation
        lastTranslation = translation
    }
}
