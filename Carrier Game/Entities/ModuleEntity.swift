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
    
    func makeNode() -> SKNode {
        
        print("&& MODULE ATTR: \(instance.blueprint.attributes). ENTRANCES: \(instance.blueprint.entrances). WALLS?: \(instance.blueprint.automaticWalls)")
        
        let textureNode = SKNode()
        let placement = instance.placement
        textureNode.position = CGPoint(x: CGFloat(placement.origin.x), y: CGFloat(placement.origin.y))
        for node in makeTextureNodes() {
            textureNode.addChild(node)
        }
        return textureNode
    }
    
    // TODO: TOO MUCH LOGIC. NEED SKSPRITENODE SUBCLASS TO DETERMINE COLOR, TEXTURE, ETC
    private func makeTextureNodes() -> [SKNode] {
        // Create rect in local space (not translated to deck)
        let localRect = GridRect(origin: .zero, size: instance.rect.size)
        // Get module's wall points from blueprint
        let borderPoints = Set(instance.blueprint.wallCoords)
        // Add nodes for each coord in module
        var nodes = [SKNode]()
        for x in localRect.xRange {
            for y in localRect.yRange {
                // A node is always made
                let node: SKSpriteNode
                let size = CGSize(width: 1, height: 1)
                let position = CGPoint(x: x, y: y)
                // Assign position and add when finished
                defer {
                    node.position = position
                    nodes.append(node)
                }
                // Check whether this is a wall
                guard !borderPoints.contains(GridPoint3(position, 0)) else {
                    node = SKSpriteNode(imageNamed: "Barrel")
                    node.size = size
                    continue
                }
                // Check whether this is an entrance
                if let entrance = instance.blueprint.entrances.first(where: { $0.coordinate == CDPoint2(x: CGFloat(x), y: CGFloat(y)) }) {
                    if entrance.zAccess {
                        node = SKSpriteNode(color: .yellow, size: size)
                    } else {
                        node = SKSpriteNode(color: .brown, size: size)
                    }
                } else {
                    node = SKSpriteNode(color: .brown, size: size)
                }
            }
        }
        return nodes
    }
}
