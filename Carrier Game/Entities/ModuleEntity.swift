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
    
    init(placement: ModulePlacement) {
        self.placement = placement
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let placement: ModulePlacement
    
    var blueprint: ModuleBlueprint { return placement.blueprint }
    
    // TODO: Should be a node component that adheres to protocol since entity should not care whether it's in 2D or 3D environment?
    private(set) lazy var mainNodeComponent: GKSKNodeComponent = {
        // Add component and return
        let component = GKSKNodeComponent(node: makeMainNode())
        addComponent(component)
        return component
    }()
    
    // MARK: - Methods
    
    func makeGraph() -> GKGridGraph3D<GKGridGraphNode3D> {
        let wallCoords = Set(placement.absoluteWallCoords)
        // Make graph and add nodes
        let graph = GKGridGraph3D([])
        for coord in placement.absoluteRect.allPoints {
            guard !wallCoords.contains(coord) else { continue }
            graph.connectToAdjacentNodes(GKGridGraphNode3D(point: coord))
        }
        return graph
    }
    
    private func makeMainNode() -> SKNode {
        // Make main node
        let mainNode = SKNode()
        mainNode.name = "Module: \(String(describing: self))"
        mainNode.position = CGPoint(placement.origin)
        mainNode.zRotation = CGFloat(placement.rotation.radians)
        // NOTE: Texture nodes are placed according to *relative* position since they are attached to one main node that is placed at the placement's origin and rotated as needed.
        let borderPoints = Set(blueprint.wallCoords)
        for x in GridPoint.zero..<GridPoint(blueprint.size.x) {
            for y in GridPoint.zero..<GridPoint(blueprint.size.y) {
                let point = CDPoint2(x: x, y: y)
                // A node is always made
                let node: SKSpriteNode
                let size = CGSize(width: 1, height: 1)
                let position = CGPoint(x: x, y: y)
                // Assign position and add when finished
                defer {
                    node.name = "Texture"
                    node.position = position
                    mainNode.addChild(node)
                }
                // Check whether this is a wall
                guard !borderPoints.contains(point) else {
                    node = SKSpriteNode(imageNamed: "Barrel")
                    node.size = size
                    continue
                }
                // Check whether this is an entrance
                if let entrance = blueprint.entrances.first(where: { $0.coordinate == point }) {
                    if entrance.zAccess {
                        node = SKSpriteNode(color: .yellow, size: size)
                    } else {
                        node = SKSpriteNode(color: .brown, size: size)
                    }
                    continue
                }
                // Otherwise simply open, no-entrance texture
                node = SKSpriteNode(color: .white, size: size)
            }
        }
        return mainNode
    }
}
