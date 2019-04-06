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

class Deck2DViewController<SceneType>: UIViewController, UIGestureRecognizerDelegate where SceneType: BaseDeck2DScene {
    
    // MARK: - Initialization
    
    init(scene: SceneType, ship: ShipBlueprint) {
        self.scene = scene
        self.ship = ship
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let scene: SceneType
    let ship: ShipBlueprint
    var shipEntity: ShipEntity { return scene.shipEntity }
    
    private(set) lazy var logger = Logger(source: type(of: self))
    
    private var skView: SKView {
        return view as! SKView
    }
    
//    private(set) lazy var scene: BaseDeck2DScene = {
//        let scene = BaseDeck2DScene(ship: ship, size: CGSize(width: 50, height: 50))
//        scene.scaleMode = .aspectFit
//        // Add camera
//        scene.addChild(camera)
//        scene.camera = camera
//        return scene
//    }()
    
    var cameraScale: CGFloat = 1.0 {
        didSet { camera.setScale(cameraScale) }
    }
    
    private(set) lazy var sceneController: SceneController<BaseDeck2DScene> = {
        return SceneController(scene: scene, context: NSPersistentContainer.model.viewContext)
    }()
    
    private(set) lazy var camera: SKCameraNode = {
        let node = SKCameraNode()
        node.setScale(cameraScale)
        return node
    }()
    
    private var lastTranslation: CGPoint = .zero
    
    // MARK: - Methods
    
    override func loadView() {
        view = SKView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup scene
        setupScene()
        // Setup camera
        setupCamera()
        // Setup recognizers
        setupRecognizers()
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
    
    func nextDeck() -> DeckEntity {
        if scene.visibleDeck == shipEntity.deckEntities.last {
            return shipEntity.deckEntities.first!
        } else {
            return shipEntity.deck(at: Int(scene.visibleDeck.blueprint.position + 1))!
        }
    }
    
    func previousDeck() -> DeckEntity {
        if scene.visibleDeck == shipEntity.deckEntities.first {
            return shipEntity.deckEntities.last!
        } else {
            return shipEntity.deck(at: Int(scene.visibleDeck.blueprint.position - 1))!
        }
    }
    
    private func setupScene() {
        // Configure scene
        scene.scaleMode = .aspectFit
        // - Scale mode
        scene.addChild(camera)
        // - Camera
        scene.camera = camera
        // Present
        skView.presentScene(scene)
    }
    
    private func setupCamera() {
        // TODO: ALL TEMPORARY
        camera.position = CGPoint(x: 0, y: 0)
        cameraScale = 0.3
    }
    
    func setupRecognizers() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(recognizedPan(_:)))
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(recognizedTap(_:)))
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(recognizedPinch(_:)))
        for recognizer in [panRecognizer, tapRecognizer, pinchRecognizer] {
            view.addGestureRecognizer(recognizer)
            recognizer.delegate = self
        }
    }
    
    // MARK: Actions
    
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
        logger.logInfo("Tapped grid point: \(GridPoint(point.x)), \(GridPoint(point.y)).")
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
    
    // MARK: UIGestureRecognizer Delegate Implementation
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // By default only recognize our gestures if they're occurring directly on the root (scene) view
        return touch.view == view
    }
}
