//
//  Module.swift
//  Carrier Game
//
//  Created by Sean G Young on 10/26/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData
import GameKit
import SGYSwiftUtility

public class ModuleBlueprint: NSManagedObject, IdentifiableEntity {
    
    @NSManaged var name: String
    @NSManaged var identifier: String
    @NSManaged var size: CDPoint2
    @NSManaged var xyOpenCoords: Set<CDPoint2>
    @NSManaged var zOpenCoords: Set<CDPoint2>
    
    @NSManaged var fulfilledNeeds: Set<ModuleNeedBlueprint>
    @NSManaged var jobs: Set<ModuleJobBlueprint>
    
    // TODO: MOVE TO ENTITY?
    private(set) lazy var textureNodes: [SKNode] = {
        return makeTextureNodes()
    }()
}

extension ModuleBlueprint {
    
    private func makeTextureNodes() -> [SKNode] {
        // Convert open coords to correctly typed sets
        let zOpenVectors: Set<vector_int2> = Set(zOpenCoords)
        let xyOpenVectors: Set<vector_int2> = Set(xyOpenCoords)
        // Add nodes for each coord in module
        var nodes = [SKNode]()
        for x in 0..<Int32(size.x) {
            for y in 0..<Int32(size.y) {
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
