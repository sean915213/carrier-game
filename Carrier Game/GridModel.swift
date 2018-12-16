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

typealias GridPoint = Int

/// Represents a rect in game (similar to CGRect in 3D) but uses a slightly different coordinate system where a rect of size 1, 1 and origin 0, 0 only contains the origin coordinate. Each 1x1 grid section has origin at bottom left for purposes of determining whether floats are contained.
struct GridRect {
    
    init(origin: GridPoint3, size: GridPoint3) {
        self.origin = origin
        // Do not allow negative sizes
        self.size = GridPoint3(abs(size.x), abs(size.y), abs(size.z))
    }
    
    var origin: GridPoint3
    var size: GridPoint3
    
    var xRange: Range<GridPoint> { return origin.x..<(origin.x + size.x) }
    var yRange: Range<GridPoint> { return origin.y..<(origin.y + size.y) }
    var zRange: Range<GridPoint> { return origin.z..<(origin.z + size.z) }
    
    func contains(_ point: GridPoint3) -> Bool {
        return xRange.contains(point.x) && yRange.contains(point.y) && zRange.contains(point.z)
    }
}

// Defined because conversion between floating point types and an integer point on the grid is done in a specific way. So rather than creating extension on generic Int32 define our own type with this understood behavior
extension GridPoint {
    
    init(point: Float) {
        self = Int(floor(point))
    }
}

// Defined because conversion between other types and this int3 alias is done in a specific fashion. So rather than creating extension on generic int3 define our own type with this understood behavior
struct GridPoint3: Hashable, Equatable {
    
    init(_ point: float3) {
        self.init(GridPoint(point.x), GridPoint(point.y), GridPoint(point.z))
    }
    
    init(_ point: CDPoint3) {
        self.init(GridPoint(point.x), GridPoint(point.y), GridPoint(point.z))
    }
    
    init(_ point: CDPoint2, _ z: GridPoint) {
        self.init(GridPoint(point.x), GridPoint(point.y), z)
    }
    
    init(_ point: CGPoint, _ z: GridPoint) {
        self.init(GridPoint(point.x), GridPoint(point.y), z)
    }
    
    init(_ x: GridPoint, _ y: GridPoint, _ z: GridPoint) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    var x: GridPoint
    var y: GridPoint
    var z: GridPoint
}

extension GridPoint3 {
    
    static func +(left: GridPoint3, right: GridPoint3) -> GridPoint3 {
        return GridPoint3(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    
    static func -(left: GridPoint3, right: GridPoint3) -> GridPoint3 {
        return GridPoint3(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    
    static func +=(left: inout GridPoint3, right: GridPoint3) {
        left = left + right
    }
    
    static func -=(left: inout GridPoint3, right: GridPoint3) {
        left = left - right
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
    
    var gridNodes: [NodeType]? { return nodes as? [NodeType] }
    
    private(set) var positions = [GridPoint3: NodeType]()
    
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
        self.init(x: Float(point.x), y: Float(point.y), z: Float(point.z))
    }
}

extension float3 {
    init(_ point: GridPoint3) {
        self.init(x: Float(point.x), y: Float(point.y), z: Float(point.z))
    }
}
