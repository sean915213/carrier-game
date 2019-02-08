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
        textureNode.name = "Deck [\(instance.placement.position)]"
        for module in moduleEntities {
            textureNode.addChild(module.mainNodeComponent.node)
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
