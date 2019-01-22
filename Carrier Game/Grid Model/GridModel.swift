//
//  GridModel.swift
//  Carrier Game
//
//  Created by Sean G Young on 12/8/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit
import GameplayKit
import SGYSwiftUtility

/// Represents a rect in game (similar to CGRect in 3D) but uses a slightly different coordinate system where a rect of size 1, 1 and origin 0, 0 only contains the origin coordinate. Each 1x1 grid section has origin at bottom left for purposes of determining whether floats are contained.
struct GridRect {
    
    var origin: GridPoint3
    var size: GridPoint3
    
    // TODO: Cannot make lazy due to struct limitations. But could be expensive to constantly use for contains, etc. Should be class instead? Need to benchmark at some point.
    // TODO: ORR- Can just store a constant that gets initialized lazily? Seems to be a weird workaround to struct mechanics.
    // NOTE: Must turn stride into array as typical methods (at least `contains`) do not work properly on negative strides
    var xRange: [GridPoint] {
        guard size.x != GridPoint(0) else { return [] }
        return Array(stride(from: origin.x, to: origin.x + size.x, by: size.x.rawValue.signum()))
    }
    var yRange: [GridPoint] {
        guard size.y != GridPoint(0) else { return [] }
        return Array(stride(from: origin.y, to: origin.y + size.y, by: size.y.rawValue.signum()))
    }
    var zRange: [GridPoint] {
        guard size.z != GridPoint(0) else { return [] }
        return Array(stride(from: origin.z, to: origin.z + size.z, by: size.z.rawValue.signum()))
    }
    
    var allPoints: [GridPoint3] {
        var points = [GridPoint3]()
        for x in xRange {
            for y in yRange {
                for z in zRange {
                    points.append(GridPoint3(x, y, z))
                }
            }
        }
        return points
    }
    
    // TODO: STILL USED? Not using because only useful in determining walls in a module, so far. And a simple "contains" contains every point since module rects are only 1 z-range length (so all coords are a border due to no top or bottom 'deck')
    var borderPoints: [GridPoint3] {
        var points = [GridPoint3]()
        for point in allPoints {
            guard point.x == xRange.first || point.x == xRange.last ||
                point.y == yRange.first || point.y == yRange.last ||
                point.z == zRange.first || point.z == zRange.last else { continue }
            points.append(point)
        }
        return points
    }
    
    func contains(_ point: GridPoint3) -> Bool {
        return xRange.contains(point.x) && yRange.contains(point.y) && zRange.contains(point.z)
    }
    
    func rotated(by magnitude: GridRotation, around axis: GridAxis) -> GridRect {
        // Get vector pointing to other corner
        let cornerVector = GridPoint3(size.x - origin.x, size.y - origin.y, size.z - origin.z)
        // Rotate
        let rotatedVector = cornerVector.rotated(by: magnitude, around: axis)
        // Assign new size based on coords
        var rotatedRect = self
        rotatedRect.size.x = rotatedVector.x
        rotatedRect.size.y = rotatedVector.y
        rotatedRect.size.z = rotatedVector.z
        return rotatedRect
    }
}

class GKGridGraphNode3D: GKGraphNode {
    
    init(point: GridPoint3) {
        position = point
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

extension CDPoint3 {
    convenience init(_ point: GridPoint3) {
        self.init(x: Float(point.x.rawValue), y: Float(point.y.rawValue), z: Float(point.z.rawValue))
    }
}
