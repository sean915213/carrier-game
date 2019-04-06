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
        // Currently assuming a ship must have a 'root' deck.
        visibleDeck = shipEntity.deck(at: 0)!
        super.init(size: size)
        // Setup
        displayDeck(entity: visibleDeck)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let shipEntity: ShipEntity
    private(set) lazy var logger = Logger(source: type(of: self))
    
    private(set) var visibleDeck: DeckEntity
    
    // MARK: - Methods
    
    func displayDeck(entity: DeckEntity) {
        logger.logInfo("Displaying deck: \(entity.blueprint.position).")
        // Remove old deck's node and add new
        visibleDeck.node.removeFromParent()
        addChild(entity.node)
        // Assign new deck
        visibleDeck = entity
    }
}
