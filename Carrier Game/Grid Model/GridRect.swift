//
//  GridRect.swift
//  Carrier Game
//
//  Created by Sean G Young on 1/26/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import Foundation

// TODO: ALMOST CERTAINLY MAKE GRIDRECT A CLASS DUE TO TONS OF USES OF RANGES??

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
    
    func contains(_ point: GridPoint3) -> Bool {
        return xRange.contains(point.x) && yRange.contains(point.y) && zRange.contains(point.z)
    }
    
    func rotated(by magnitude: GridRotation, around axis: GridAxis) -> GridRect {
        // Rotate this size point (essentially a vector in local space pointing to the far-most corner of this rect)
        let rotatedSize = size.rotated(by: magnitude, around: axis)
        return GridRect(origin: origin, size: rotatedSize)
    }
}
