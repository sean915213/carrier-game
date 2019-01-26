//
//  GKGridGraph3D.swift
//  Carrier Game
//
//  Created by Sean G Young on 12/8/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit
import GameplayKit
import SGYSwiftUtility

class GKGridGraphNode3D: GKGraphNode {
    
    // MARK: - Initialization
    
    init(point: GridPoint3) {
        position = point
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    var position: GridPoint3
    
    override var description: String {
        return "GKGridGraphNode3D: {\(position.x), \(position.y), \(position.z)}"
    }
}

class GKGridGraph3D<NodeType>: GKGraph where NodeType: GKGridGraphNode3D {
    
    // MARK: - Initialization
    
    init(_ nodes: [NodeType]) {
        super.init()
        add(nodes)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    private(set) var positions = [GridPoint3: NodeType]()
    
    var gridNodes: [NodeType]? { return nodes as? [NodeType] }
    
    private lazy var logger = Logger(source: type(of: self))
    
    // MARK: - Methods
    
    func node(atPoint point: GridPoint3) -> NodeType? {
        return positions[point]
    }
    
    func connectToAdjacentNodes(_ node: NodeType) {
        // Add
        add([node])
        // Find adjacent nodes and make connections
        var adjacentNodes = [NodeType]()
        // +X
        if let adjacent = positions[node.position + GridPoint3(1, 0, 0)] { adjacentNodes.append(adjacent) }
        // -X
        if let adjacent = positions[node.position + GridPoint3(-1, 0, 0)] { adjacentNodes.append(adjacent) }
        // +Y
        if let adjacent = positions[node.position + GridPoint3(0, 1, 0)] { adjacentNodes.append(adjacent) }
        // -Y
        if let adjacent = positions[node.position + GridPoint3(0, -1, 0)] { adjacentNodes.append(adjacent) }
        // +Z
        if let adjacent = positions[node.position + GridPoint3(0, 0, 1)] { adjacentNodes.append(adjacent) }
        // -Z
        if let adjacent = positions[node.position + GridPoint3(0, 0, -1)] { adjacentNodes.append(adjacent) }
        // Add connections
        node.addConnections(to: adjacentNodes, bidirectional: true)
    }
    
    func addGraph(_ graph: GKGridGraph3D<NodeType>, connectAdjacentNodes: Bool) {
        let nodes = graph.gridNodes ?? []
        // If not connecting then just add
        guard connectAdjacentNodes else {
            add(nodes)
            return
        }
        // Otherwise perform connection
        for node in nodes { connectToAdjacentNodes(node) }
    }
    
    override func add(_ nodes: [GKGraphNode]) {
        var validNodes = [NodeType]()
        for node in nodes {
            // Check type requirements
            guard let properNode = node as? NodeType else {
                assertionFailure("Incorrect GKGraphNode type.")
                continue
            }
            // If node exists then skip
            guard positions[properNode.position] == nil else {
                logger.logError("Attempted to add node with duplicate position. Skipping.")
                continue
            }
            // Add to valid and positions
            validNodes.append(properNode)
            positions[properNode.position] = properNode
        }
        // Chain to super
        super.add(validNodes)
    }

    override func remove(_ nodes: [GKGraphNode]) {
        guard let properNodes = nodes as? [NodeType] else {
            assertionFailure("Incorrect GKGraphNode type.")
            return
        }
        super.remove(nodes)
        // Remove entries
        for node in properNodes { positions.removeValue(forKey: node.position) }
    }

    override func connectToLowestCostNode(node: GKGraphNode, bidirectional: Bool) {
        fatalError("Not implemented. Should this be implemented?")
    }
}

extension Sequence where Element: GKGridGraphNode3D {
    func first(atPoint point: GridPoint3) -> Element? {
        return first { $0.position == point }
    }
}
