//
//  ModuleEntity.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/12/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import SpriteKit
import GameplayKit

// TODO NEXT: makeTextureNodes() is wrong. Using absolute positioning, but node hierarchy dictates a relative position. So texture placement is probably off?? Would explain issues with click translation to relative deck coords?

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
        
//        print("&& MODULE ATTR: \(instance.blueprint.attributes). ENTRANCES: \(instance.blueprint.entrances). WALLS?: \(instance.blueprint.automaticWalls). ROTATION: \(instance.placement.rotation)")
        
        let textureNode = SKNode()
        textureNode.name = "Module: \(String(describing: self))"
        let placement = instance.placement
        
        textureNode.position = CGPoint(x: CGFloat(placement.origin.x), y: CGFloat(placement.origin.y))
        
        print("&& MODULE TEXTURE NODE POSITION: \(textureNode.position)")
        
        for node in makeTextureNodes() {
            textureNode.addChild(node)
        }
        return textureNode
    }
    
    func makeGraph() -> GKGridGraph3D<GKGridGraphNode3D> {
        let wallCoords = Set(instance.absoluteWallCoords)
        // Make graph and add nodes
        let graph = GKGridGraph3D([])
        for coord in instance.absoluteRect.allPoints {
            guard !wallCoords.contains(coord) else { continue }
            graph.connectToAdjacentNodes(GKGridGraphNode3D(point: coord))
        }
        return graph
    }
    
    private func makeTextureNodes() -> [SKNode] {
        let borderPoints = Set(instance.blueprint.wallCoords)
        var nodes = [SKNode]()
        for x in GridPoint.zero..<GridPoint(instance.blueprint.size.x) {
            for y in GridPoint.zero..<GridPoint(instance.blueprint.size.y) {
                let point = CDPoint2(x: x, y: y)
                // A node is always made
                let node: SKSpriteNode
                let size = CGSize(width: 1, height: 1)
                let position = CGPoint(x: x, y: y)
                
                print("&& NODE POS: \(position)")
                
                // Assign position and add when finished
                defer {
                    node.name = "Texture"
                    node.position = position
                    nodes.append(node)
                }
                // Check whether this is a wall
                guard !borderPoints.contains(point) else {
                    node = SKSpriteNode(imageNamed: "Barrel")
                    node.size = size
                    continue
                }
                // Check whether this is an entrance
                if let entrance = instance.blueprint.entrances.first(where: { $0.coordinate == point }) {
                    if entrance.zAccess {
                        node = SKSpriteNode(color: .yellow, size: size)
                    } else {
                        node = SKSpriteNode(color: .brown, size: size)
                    }
                    continue
                }
                // Otherwise simply open, no-entrance texture
                node = SKSpriteNode(color: .red, size: size)
            }
        }
        return nodes
    }
}
