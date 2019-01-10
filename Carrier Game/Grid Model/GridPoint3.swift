//
//  GridPoint3.swift
//  Carrier Game
//
//  Created by Sean G Young on 1/9/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import Foundation
import GameplayKit

// Defined because our grid points are specific and typealiasing int3 wasn't enough.
struct GridPoint3: Hashable, Equatable {
    
    static let zero = GridPoint3(0, 0, 0)
    
    init(_ point: float3) {
        self.init(GridPoint(point.x), GridPoint(point.y), GridPoint(point.z))
    }
    
    init(_ point: CDPoint3) {
        self.init(GridPoint(point.x), GridPoint(point.y), GridPoint(point.z))
    }
    
    init(_ point: CDPoint2, _ z: Int) {
        self.init(point, GridPoint(z))
    }
    
    init(_ point: CGPoint, _ z: Int) {
        self.init(point, GridPoint(z))
    }
    
    init(_ point: CDPoint2, _ z: GridPoint) {
        self.init(GridPoint(point.x), GridPoint(point.y), z)
    }
    
    init(_ point: CGPoint, _ z: GridPoint) {
        self.init(GridPoint(point.x), GridPoint(point.y), z)
    }
    
    init(_ x: Int, _ y: Int, _ z: Int) {
        self.init(GridPoint(x), GridPoint(y), GridPoint(z))
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

extension GridPoint3 {
    
    enum RotationAxis { case z }
    
    // TODO: Should probably just be using real matrix operations rather than requiring an axis enum?
    func rotated(by angle: Float, around axis: RotationAxis, origin: GridPoint3 = .zero) -> GridPoint3 {
        switch axis {
        case .z:
            var point = self
            // Translate to origin
            point -= origin
            // Get rotations
            let s = sin(angle)
            let c = cos(angle)
            // Assign translated coords
            let xCoord = Float(point.x) * c - Float(point.y) * s
            let yCoord = Float(point.x) * s + Float(point.y) * c
            // Assign new coords
            point.x = GridPoint(xCoord)
            point.y = GridPoint(yCoord)
            // Return result translated back from origin
            return origin + point
        }
    }
    
    
}

