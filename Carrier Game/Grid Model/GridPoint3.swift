//
//  GridPoint3.swift
//  Carrier Game
//
//  Created by Sean G Young on 1/9/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import Foundation
import GameplayKit
import Accelerate

enum GridAxis {
    case z
}

@objc enum GridRotation: Int16, CustomDebugStringConvertible {
    case none, quarter, half, threeQuarter
    
    var radians: Float {
        switch self {
        case .none: return 0
        case .quarter: return Float.pi / 2.0
        case .half: return Float.pi
        case .threeQuarter: return Float.pi + Float.pi / 2.0
        }
    }
    
    var debugDescription: String {
        switch self {
        case .none: return "none"
        case .quarter: return "quarter"
        case .half: return "half"
        case .threeQuarter: return "three quarter"
        }
    }
}

// Defined because our grid points are specific and typealiasing int3 wasn't enough.
struct GridPoint3: Hashable, Equatable {
    
    static let zero = GridPoint3(0, 0, 0)
    
    init(_ point: CDPoint3) {
        self.init(GridPoint(point.x), GridPoint(point.y), GridPoint(point.z))
    }
    
    init(_ point: CDPoint2, _ z: Int) {
        self.init(point, GridPoint(z))
    }
    
    init(_ point: CDPoint2, _ z: Int16) {
        self.init(point, GridPoint(z))
    }
    
    init(_ point: CGPoint, _ z: Int) {
        self.init(point, GridPoint(z))
    }
    
    init(_ point: GridPoint2, _ z: Int16) {
        self.init(point.x, point.y, GridPoint(z))
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
    
    // NOTE: Rotation logic largely adopted from:
    // https://developer.apple.com/documentation/accelerate/simd/working_with_matrices
    func rotated(by magnitude: GridRotation, around axis: GridAxis, origin: GridPoint3 = .zero) -> GridPoint3 {
        let angle = magnitude.radians
        // Translate point
        let point = self - origin
        // Create vector and rotation matrix
        let vector: simd_float3
        let rotation: simd_float3x3
        switch axis {
        case .z:
            // vector representing point
            vector = simd_float3([Float(point.x), Float(point.y), Float(point.z)])
            // Matrix for rotating x/y about the z-axis
            let rows = [
                simd_float3( cos(angle), sin(angle), 0),
                simd_float3(-sin(angle), cos(angle), 0),
                simd_float3( 0,          0,          1)
            ]
            rotation = float3x3(rows: rows)
        }
        // Get rotated vector
        let rotatedVector = vector * rotation
        // Return as GridPoint3
        return GridPoint3(GridPoint(rotatedVector.x), GridPoint(rotatedVector.y), GridPoint(rotatedVector.z))
    }
}

extension CDPoint3 {
    convenience init(_ point: GridPoint3) {
        self.init(x: Float(point.x.rawValue), y: Float(point.y.rawValue), z: Float(point.z.rawValue))
    }
}

