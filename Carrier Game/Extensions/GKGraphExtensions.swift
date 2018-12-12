//
//  GKGraphExtensions.swift
//  Carrier Game
//
//  Created by Sean G Young on 12/1/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import GameplayKit

extension GKGraph {
    
    func node(atPoint point: float3) -> GKGraphNode3D? {
        return nodes?.first(where: { ($0 as? GKGraphNode3D)?.position == point }) as? GKGraphNode3D
    }
}

extension GKGridGraph where NodeType == GKGridGraphNode {
    
    enum PathfindingError: Error { case invalidOrigin, invalidDestination }
    
    func node(atPoint point: CGPoint) -> NodeType? {
        return node(atGridPosition: vector_int2(point))
    }
    
    func findPath(from origin: CGPoint, to destination: CGPoint) throws -> [CGPoint] {
        guard let originNode = node(atGridPosition: vector_int2(origin)) else { throw PathfindingError.invalidOrigin }
        guard let destinationNode = node(atGridPosition: vector_int2(destination)) else { throw PathfindingError.invalidDestination }
        let nodes = findPath(from: originNode, to: destinationNode) as! [NodeType]
        return nodes.map { CGPoint($0.gridPosition) }
    }
}

extension GKGraphNode3D {
    
    open override var description: String {
        return "GKGraphNode3D: {\(position.x), \(position.y), \(position.z)}"
    }
}

extension Sequence where Element: GKGraphNode3D {
    
    func first(atPoint point: float3) -> GKGraphNode3D? {
        return first { $0.position == point }
    }
}
