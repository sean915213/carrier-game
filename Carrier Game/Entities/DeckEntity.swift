//
//  DeckEntity.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/27/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit
import GameplayKit
import SGYSwiftUtility

// TODO: NEXT.
// IN CHANGE TO ASSUME ALL OPEN COORDS IN MODULE EXCEPT IF AUTOMATICWALL IS TRUE.
// TEXTURES COMPLETE. NEED TO INTEGRATE THIS INTO CREATION OF GRID GRAPHS. SHOULD BE COMPLETED THEN.
// THENNN: ADD COORIDORS WITH FASTER MOVEMENT SPEED?
// ANNND: AUTOMATICALLY SEAL ENTRANCES IF FACING OUTSIDE SHIP?
// ANND2: BETTER SYSTEM FOR CREATING SPRITE NODES BASED ON A TYPE??

class DeckEntity: GKEntity {

    // MARK: - Initialization
    
    init(deck: DeckInstance) {
        self.instance = deck
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let instance: DeckInstance
    
    private(set) lazy var moduleEntities: [ModuleEntity] = {
        return instance.modules.map { ModuleEntity(module: $0) }
    }()
    
    // MARK: - Methods
    
    func makeNode() -> SKNode {
        let textureNode = SKNode()
        for module in moduleEntities {
            textureNode.addChild(module.makeNode())
        }
        return textureNode
    }
    
    func makeGraph() -> GKGridGraph3D<GKGridGraphNode3D> {
        let deckPosition = GridPoint(instance.blueprint.position)
        // Gather & translate coordinates to deck coordinates
        var coords = Set<GridPoint3>()
        for entity in moduleEntities {
            let wallCoords = Set(entity.instance.blueprint.wallCoords.map({ GridPoint3(entity.instance.placement.origin, deckPosition) + $0 }))
            for coord in entity.instance.rect.allPoints {
                guard !wallCoords.contains(coord) else { continue }
                coords.insert(coord)
            }
        }
        // Make graph and add nodes
        let graph = GKGridGraph3D([])
        for coord in coords {
            let node = GKGridGraphNode3D(point: coord)
            graph.connectToAdjacentNodes(node)
        }
        return graph
    }
}
