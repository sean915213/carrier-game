//
//  DeckScene.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/12/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import SpriteKit
import GameplayKit
import SGYSwiftUtility

class DeckScene: SKScene {
    
    // MARK: - Initialization
    
    init(ship: ShipInstance, size: CGSize) {
        shipEntity = ShipEntity(instance: ship)
        // TODO: Should be assuming a deck will always exist?
        visibleDeck = shipEntity.deck(at: 0)!
        super.init(size: size)
        // Setup
        setupShip()
        displayDeck(entity: visibleDeck)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let shipEntity: ShipEntity
    
    var ship: ShipInstance { return shipEntity.instance }
    
    var visibleDeck: DeckEntity {
        willSet { displayDeck(entity: newValue) }
    }
    
    lazy var activeEntities: [GKEntity] = {
        return shipEntity.allEntities
    }()
    
    private(set) lazy var reporter = StatReportingEntity()
    
    private var lastUpdate: TimeInterval = 0
    
    private lazy var logger = Logger(source: type(of: self))
    
    // MARK: - Methods
    
    private func setupShip() {
        activeEntities.append(shipEntity)
        activeEntities.append(contentsOf: shipEntity.allEntities)
        // Add crewman entities
        for crewman in shipEntity.crewmanEntities {
            // Add a 2D movement component
            crewman.addComponent(MovementComponent2D())
            // Add node to scene
            // NOTE: crewman nodes are always added regardless of the deck they're on because they hide/unhide themselves based on this fact. Keeping the nodes on scene helps time their movement on invisible decks.
            addChild(crewman.rootNode)
            // TODO: FIGURE THIS OUT
            // Raise z on crewman node
            crewman.rootNode.zPosition = 100
        }
    }
    
    func nextDeck() -> DeckEntity {
        if shipEntity.deckEntities.last == visibleDeck {
            return shipEntity.deckEntities.first!
        } else {
            return shipEntity.deck(at: Int(visibleDeck.blueprint.position + 1))!
        }
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        
        // TODO: This seems a bit hacky. Should instead just use time on ship instance and make this an animation only thing vs. an in-game time thing?
        
        // Transform to game time for entity updates
        let gameTime = currentTime * ((60 * 60) / 3.0) * 2
        
        // Assign last value when returning
        defer { lastUpdate = gameTime }
        // If lastUpdate is zero this is first update so just return
        guard lastUpdate != 0 else { return }
        // Update entities with time difference
        let dt = gameTime - lastUpdate
        for entity in activeEntities {
            entity.update(deltaTime: dt)
        }
        // Update on stat reporter AFTER entities are updated
        reporter.update(deltaTime: dt)
    }
    
    private func displayDeck(entity: DeckEntity) {
        logger.logInfo("Displaying deck: \(entity.blueprint.position).")
        // Remove old deck's node and add new
        visibleDeck.node.removeFromParent()
        addChild(entity.node)
        // Update all crewman's movement component
        for crewman in shipEntity.crewmanEntities {
            let component = crewman.component(ofType: MovementComponent2D.self)!
            component.visibleVertical = GridPoint(entity.blueprint.position)
        }
    }
}
