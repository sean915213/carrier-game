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
        let textureNode = SKNode()
        let placement = instance.placement
        textureNode.position = CGPoint(x: CGFloat(placement.origin.x), y: CGFloat(placement.origin.y))
        for node in makeTextureNodes() {
            textureNode.addChild(node)
        }
        return textureNode
    }
    
    private func makeTextureNodes() -> [SKNode] {
        let blueprint = instance.placement.blueprint
        // Convert open coords to correctly typed sets
        let zOpenVectors: Set<vector_int2> = Set(blueprint.zOpenCoords)
        let xyOpenVectors: Set<vector_int2> = Set(blueprint.xyOpenCoords)
        // Add nodes for each coord in module
        var nodes = [SKNode]()
        for x in 0..<Int32(blueprint.size.x) {
            for y in 0..<Int32(blueprint.size.y) {
                let v = vector_int2(x, y)
                
                // SIZE
                let size = CGSize(width: 1, height: 1)
                
                // Create and add node
                let node: SKSpriteNode
                
                // Check if open
                if zOpenVectors.contains(v) {
                    node = SKSpriteNode(color: .yellow, size: size)
                } else if xyOpenVectors.contains(v) {
                    node = SKSpriteNode(color: .brown, size: size)
                } else {
                    //                    let image = UIImage(named: "Barrel")!
                    //                    let texture = SKTexture(image: image)
                    
                    //                    let texture = SKTexture(imageNamed: "Barrel")
                    
                    //                    node = SKSpriteNode(texture: texture)
                    
                    node = SKSpriteNode(imageNamed: "Barrel")
                    node.size = size
                }
                node.position = CGPoint(x: Int(x), y: Int(y))
                nodes.append(node)
            }
        }
        return nodes
    }
}
