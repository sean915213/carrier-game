//
//  ModuleEntityNodeComponent2D.swift
//  Carrier Game
//
//  Created by Sean G Young on 2/15/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit
import GameplayKit

class ModuleEntityNodeComponent2D: GKSKNodeComponent {
    
    // MARK: - Initialization
    
    override init() {
        // NOTE: Despite being defined as non-optional, must actually pass/assign an SKNode to GKSKNodeComponent or crashes ensue
        super.init(node: SKNode())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    private var placement: ModulePlacement? {
        return (entity as? ModuleEntity)?.placement
    }
    
    private var positionObserver: NSKeyValueObservation?
    
    // MARK: - Methods
    
    override func didAddToEntity() {
        super.didAddToEntity()
        configureNode()
        configureObserver()
    }

    private func configureNode() {
        guard let placement = placement else {
            fatalError("\(#function) called without an assigned placement.")
        }
        let blueprint = placement.blueprint
        // Configure node
        node.name = "Module: \(String(describing: self))"
        node.position = CGPoint(placement.origin)
        node.zRotation = CGFloat(placement.rotation.radians)
        // NOTE: Texture nodes are placed according to *relative* position since they are attached to one main node that is placed at the placement's origin and rotated as needed.
        let borderPoints = Set(blueprint.wallCoords)
        for x in GridPoint.zero..<GridPoint(blueprint.size.x) {
            for y in GridPoint.zero..<GridPoint(blueprint.size.y) {
                let point = CDPoint2(x: x, y: y)
                // A node is always made
                let childNode: SKSpriteNode
                let size = CGSize(width: 1, height: 1)
                let position = CGPoint(x: x, y: y)
                // Assign position and add when finished
                defer {
                    childNode.name = "Texture"
                    childNode.position = position
                    node.addChild(childNode)
                }
                // Check whether this is a wall
                guard !borderPoints.contains(point) else {
                    childNode = SKSpriteNode(imageNamed: "Barrel")
                    childNode.size = size
                    continue
                }
                // Check whether this is an entrance
                if let entrance = blueprint.entrances.first(where: { $0.coordinate == point }) {
                    if entrance.zAccess {
                        childNode = SKSpriteNode(color: .yellow, size: size)
                    } else {
                        childNode = SKSpriteNode(color: .brown, size: size)
                    }
                    continue
                }
                // Otherwise simply open, no-entrance texture
                childNode = SKSpriteNode(color: .white, size: size)
            }
        }
    }
    
    private func configureObserver() {
        positionObserver = (entity as! ModuleEntity).placement.observe(\ModulePlacement.origin, changeHandler: { placement, _ in
            print("-- COMPONENT CHANGING POSITION")
            self.node.position = CGPoint(placement.origin)
        })
    }
    
}
