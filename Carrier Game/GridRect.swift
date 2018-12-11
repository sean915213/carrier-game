//
//  GridRect.swift
//  Carrier Game
//
//  Created by Sean G Young on 12/8/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit
import GameplayKit

typealias GridPoint = int3

/// Represents a rect in game (similar to CGRect in 3D) but uses a slightly different coordinate system where a rect of size 1, 1 and origin 0, 0 only contains the origin coordinate. Each 1x1 grid section has origin at bottom left for purposes of determining whether floats are contained.
struct GridRect {
    
    init(origin: GridPoint, size: GridPoint) {
        self.origin = origin
        // Do not allow negative sizes
        self.size = GridPoint([abs(size.x), abs(size.y), abs(size.z)])
    }
    
    var origin: GridPoint
    var size: GridPoint
    
    var xRange: Range<Int32> { return origin.x..<(origin.x + size.x) }
    var yRange: Range<Int32> { return origin.y..<(origin.y + size.y) }
    var zRange: Range<Int32> { return origin.z..<(origin.z + size.z) }
    
    func contains(_ point: GridPoint) -> Bool {
        return xRange.contains(point.x) && yRange.contains(point.y) && zRange.contains(point.z)
    }
}

// Defined because conversion between other types and this int3 alias is done in a specific fashion. So rather than creating extension on generic int3 define our own type with this understood behavior
extension GridPoint {
    
    init(_ point: float3) {
        self.init([Int32(floor(point.x)), Int32(floor(point.y)), Int32(floor(point.z))])
    }
    
    init(_ point: CDPoint3) {
        self.init([Int32(floor(point.x)), Int32(floor(point.y)), Int32(floor(point.z))])
    }
    
    init(_ point: CGPoint, _ z: Int32) {
        self.init([Int32(floor(point.x)), Int32(floor(point.y)), z])
    }
}
