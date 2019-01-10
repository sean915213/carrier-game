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
// AUTOMATICALLY SEAL ENTRANCES IF FACING OUTSIDE SHIP?
// ANND: BETTER SYSTEM FOR CREATING SPRITE NODES BASED ON A TYPE??

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
        
        print("&& OPEN ENTRANCES: \(instance.findOpenCoords())")
        
        let textureNode = SKNode()
        for module in moduleEntities {
            textureNode.addChild(module.makeNode())
        }
        return textureNode
    }
    
    func makeGraph() -> GKGridGraph3D<GKGridGraphNode3D> {
        // Make graph and connect individual module graphs
        let graph = GKGridGraph3D([])
        for entity in moduleEntities {
            graph.addGraph(entity.makeGraph(), connectAdjacentNodes: true)
        }
        return graph
    }
}
