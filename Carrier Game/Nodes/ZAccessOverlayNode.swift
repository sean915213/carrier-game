//
//  ZAccessOverlayNode.swift
//  Carrier Game
//
//  Created by Sean G Young on 4/1/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit
import SpriteKit

class ZAccessOverlayNode: SKNode {
    
    // MARK: - Initialization
    
    init(ship: ShipBlueprint) {
        self.ship = ship
        super.init()
        updateNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let ship: ShipBlueprint
    
    var deckIndex: Int = 0
    
    // MARK: - Methods
    
    private func updateNodes() {
        // Remove current nodes
        children.forEach { $0.removeFromParent() }
        // Add overlays for upper and lower deck lifts
        let orderedDecks = ship.orderedDecks
        if deckIndex != orderedDecks.startIndex {
            // Display overlays
            addOverlaysForLifts(on: orderedDecks[orderedDecks.index(before: deckIndex)])
        }
        if deckIndex != (orderedDecks.endIndex - 1) {
            // Display overlays
            addOverlaysForLifts(on: orderedDecks[orderedDecks.index(after: deckIndex)])
        }
    }
    
    private func addOverlaysForLifts(on deck: DeckBlueprint) {
        // Add nodes
        for modulePlacement in deck.modulePlacements {
            for moduleEntrance in modulePlacement.absoluteEntrances {
                guard moduleEntrance.zAccess else { continue }
                let position = CGPoint(x: moduleEntrance.coordinate.x, y: moduleEntrance.coordinate.y)
                // Add node
                let node = SKSpriteNode(color: .orange, size: CGSize(width: 1, height: 1))
                node.position = position
                addChild(node)
            }
        }
    }
}
