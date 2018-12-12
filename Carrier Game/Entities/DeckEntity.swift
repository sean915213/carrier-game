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
    
    private(set) lazy var graphNodes: [GKGraphNode3D] = {
        return makeGraphNodes()
    }()
    
    // MARK: - Methods
    
    func makeNode() -> SKNode {
        let textureNode = SKNode()
        for module in moduleEntities {
            textureNode.addChild(module.makeNode())
        }
        return textureNode
    }
    
    private func makeGraphNodes() -> [GKGraphNode3D] {
        let deckPosition = Int(instance.blueprint.position)
        // Gather & translate coordinates to deck coordinates
        var coords = Set<CDPoint2>()
        for entity in moduleEntities {
            let blueprint = entity.instance.blueprint
            let addCoord = { (coord: CDPoint2) in
                // Translate coordinate by adding module origin to placement origin
                let realCoord = entity.instance.placement.origin + coord
                coords.insert(realCoord)
            }
            for coord in blueprint.xyOpenCoords { addCoord(coord) }
            for coord in blueprint.zOpenCoords { addCoord(coord) }
        }
        // Make and connect nodes
        var nodes = [GKGraphNode3D]()
        for coord in coords {
            // Make node
            let node = GKGraphNode3D(point: float3(point: coord, vertical: Int(instance.blueprint.position)))
            // Search for surrounding nodes. No efficient way to do this since they're in a set without ordering which may just move work to something else
            var adjacentNodes = [GKGraphNode3D]()
            // UP
            if let adjacent = nodes.first(atPoint: float3(point: coord + CDPoint2(x: 0, y: 1), vertical: deckPosition)) {
                adjacentNodes.append(adjacent)
            }
            // RIGHT
            if let adjacent = nodes.first(atPoint: float3(point: coord + CDPoint2(x: 1, y: 0), vertical: deckPosition)) {
                adjacentNodes.append(adjacent)
            }
            // DOWN
            if let adjacent = nodes.first(atPoint: float3(point: coord + CDPoint2(x: 0, y: -1), vertical: deckPosition)) {
                adjacentNodes.append(adjacent)
            }
            // LEFT
            if let adjacent = nodes.first(atPoint: float3(point: coord + CDPoint2(x: -1, y: 0), vertical: deckPosition)) {
                adjacentNodes.append(adjacent)
            }
            // Make connections
            node.addConnections(to: adjacentNodes, bidirectional: true)
            // Insert
            nodes.append(node)
        }
        return nodes
    }
}
