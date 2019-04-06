//
//  BaseDeck2DScene.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/12/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import SpriteKit
import GameplayKit
import SGYSwiftUtility

class BaseDeck2DScene: SKScene {
    
    // MARK: - Initialization
    
    init(ship: ShipBlueprint, size: CGSize) {
        shipEntity = ShipEntity(blueprint: ship)
        // TODO: Should be assuming a deck will always exist?
        visibleDeck = shipEntity.deck(at: 0)!
        super.init(size: size)
        // Setup
//        setupShip()
        displayDeck(entity: visibleDeck)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let shipEntity: ShipEntity
    private(set) lazy var logger = Logger(source: type(of: self))
    
    var visibleDeck: DeckEntity {
        willSet { displayDeck(entity: newValue) }
    }
    
    // INSTANCE -> BLUEPRINT COMMENTED LOGIC
//    var activeEntities: [GKEntity] {
//        var entities = shipEntity.allEntities
//        entities.append(shipEntity)
//        return entities
//    }
    
//    private(set) lazy var reporter = StatReportingEntity()
//
//    private var lastUpdate: TimeInterval = 0
    
    // MARK: - Methods
    
    private func setupShip() {
        // INSTANCE -> BLUEPRINT COMMENTED LOGIC
        // Add crewman entities
//        for crewman in shipEntity.crewmanEntities {
//
//            print("&& ASSIGNING CREWMAN MOVE COMPONENT")
//
//            // Add a 2D movement component
//            crewman.addComponent(MovementComponent2D())
//            // Add node to scene
//            // NOTE: crewman nodes are always added regardless of the deck they're on because they hide/unhide themselves based on this fact. Keeping the nodes on scene helps time their movement on invisible decks.
//            addChild(crewman.rootNode)
//            // TODO: FIGURE THIS OUT
//            // Raise z on crewman node
//            crewman.rootNode.zPosition = 100
//        }
    }

//    override func update(_ currentTime: TimeInterval) {
//        super.update(currentTime)
//        // If simulation not enabled then do nothing
//        guard enableSimulation else { return }
//        // Save this update
//        defer { lastUpdate = currentTime }
//        // If lastUpdate is 0 then do nothing yet
//        guard lastUpdate != 0 else { return }
//        // Get real-time difference
//        let dt = currentTime - lastUpdate
//        // Convert to game time delta
//        let gameDT = dt * ((60 * 60) / 3.0) * 2
//        // Apply to active entities
//        for entity in activeEntities { entity.update(deltaTime: gameDT) }
//        // Update on stat reporter AFTER entities are updated
//        reporter.update(deltaTime: gameDT)
//    }
    
    private func displayDeck(entity: DeckEntity) {
        logger.logInfo("Displaying deck: \(entity.blueprint.position).")
        // Remove old deck's node and add new
        visibleDeck.node.removeFromParent()
        addChild(entity.node)
        
        // INSTANCE -> BLUEPRINT COMMENTED LOGIC
//        // Update all crewman's movement component
//        for crewman in shipEntity.crewmanEntities {
//            let component = crewman.component(ofType: MovementComponent2D.self)!
//            component.visibleVertical = GridPoint(entity.blueprint.position)
//        }
    }
}
