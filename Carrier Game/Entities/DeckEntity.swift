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
    
    init(blueprint: DeckBlueprint) {
        self.blueprint = blueprint
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let blueprint: DeckBlueprint
    
    private(set) lazy var moduleEntities: [ModuleEntity] = {
        return blueprint.modulePlacements.map { ModuleEntity(placement: $0) }
    }()
    
    // MARK: - Methods
    
    func makeNode() -> SKNode {
        let textureNode = SKNode()
        textureNode.name = "Deck [\(blueprint.position)]"
        for module in moduleEntities {
            textureNode.addChild(module.mainNodeComponent.node)
        }
        return textureNode
    }
}
