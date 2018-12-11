//
//  ModuleEntity.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/12/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import SpriteKit
import GameplayKit

class ModuleEntity: GKEntity {
    
    // MARK: - Initialization
    
    init(module: ModuleInstance) {
        self.instance = module
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let instance: ModuleInstance
    
    // MARK: - Methods
    
    func makeTextureNode() -> SKNode {
        let textureNode = SKNode()
        let placement = instance.placement
        textureNode.position = CGPoint(x: CGFloat(placement.origin.x), y: CGFloat(placement.origin.y))
        for node in placement.blueprint.textureNodes { textureNode.addChild(node) }
        return textureNode
    }
}
