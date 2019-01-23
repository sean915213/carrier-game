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
        
        print("&& MODULE ATTR: \(instance.blueprint.attributes). ENTRANCES: \(instance.blueprint.entrances). WALLS?: \(instance.blueprint.automaticWalls). ROTATION: \(instance.placement.rotation)")
        
        let textureNode = SKNode()
        let placement = instance.placement
        
        textureNode.position = CGPoint(x: CGFloat(placement.origin.x), y: CGFloat(placement.origin.y))
        
        for node in makeTextureNodes() {
            textureNode.addChild(node)
        }
        return textureNode
    }
    
    func makeGraph() -> GKGridGraph3D<GKGridGraphNode3D> {
        let wallCoords = Set(instance.absoluteWallCoords)
        
        for coord in wallCoords {
            print("&& WALL COORD: \(coord)")
        }
        
        // Make graph and add nodes
        let graph = GKGridGraph3D([])
        for coord in instance.rect.allPoints {
            guard !wallCoords.contains(coord) else { continue }
            graph.connectToAdjacentNodes(GKGridGraphNode3D(point: coord))
        }
        return graph
    }
    
    private func makeTextureNodes() -> [SKNode] {
        let absoluteRect = instance.rect
        
//        // Get points on x-y border
//        let borderArray = instance.rect.allPoints.filter { point -> Bool in
//            return point.x == instance.rect.xRange.first || point.x == instance.rect.xRange.last ||
//                    point.y == instance.rect.yRange.first || point.y == instance.rect.yRange.last
//        }
//        let borderPoints = Set(borderArray)
        
        let borderPoints = instance.absoluteWallCoords
        
        print("&& BORDER POINTS (WORKING): \(borderPoints)")
        print("&& WALL COORDS (NOT WORKIG): \(instance.absoluteWallCoords)")
        
        // Add nodes for each coord in module
        var nodes = [SKNode]()
        for x in absoluteRect.xRange {
            for y in absoluteRect.yRange {
                // A node is always made
                let node: SKSpriteNode
                let size = CGSize(width: 1, height: 1)
                let position = CGPoint(x: x, y: y)
                // Assign position and add when finished
                defer {
                    node.position = position
                    nodes.append(node)
                }
                // Check whether this is an entrance
                if let entrance = instance.absoluteEntrances.first(where: { $0.coordinate == CDPoint2(x: CGFloat(x), y: CGFloat(y)) }) {
                    if entrance.zAccess {
                        node = SKSpriteNode(color: .yellow, size: size)
                    } else {
                        node = SKSpriteNode(color: .brown, size: size)
                    }
                    continue
                }
                // Check whether this is a wall
                guard !borderPoints.contains(GridPoint3(position, absoluteRect.origin.z)) else {
                    node = SKSpriteNode(imageNamed: "Barrel")
                    node.size = size
                    continue
                }
                // Otherwise simply open, no-entrance texture
                node = SKSpriteNode(color: .red, size: size)
            }
        }
        return nodes
    }
}
