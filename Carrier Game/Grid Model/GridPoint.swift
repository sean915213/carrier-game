//
//  GridPoint.swift
//  Carrier Game
//
//  Created by Sean G Young on 1/9/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit

// Defined because conversion between floating point types and an integer point on the grid is done in a specific way. So rather than creating extension on generic Int32 define our own type with this understood behavior
struct GridPoint: RawRepresentable, Hashable {
    
    static let zero = GridPoint(0)
    
    init(_ point: Float) {
        self.init(CGFloat(round(point)))
    }
    
    init(_ point: Int16) {
        self.init(Int(point))
    }
    
    init(_ point: Int) {
        self.init(rawValue: point)
    }
    
    // ULTIMATE ROUNDER OF FLOATS
    init(_ point: CGFloat) {
        self.init(Int(round(point)))
    }
    
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    var rawValue: Int
}

extension GridPoint: CustomDebugStringConvertible {
    var debugDescription: String { return String(describing: rawValue) }
}

extension GridPoint {
    
    static func +(left: GridPoint, right: GridPoint) -> GridPoint {
        return GridPoint(left.rawValue + right.rawValue)
    }
    
    static func -(left: GridPoint, right: GridPoint) -> GridPoint {
        return GridPoint(left.rawValue - right.rawValue)
    }
    
    static func +=(left: inout GridPoint, right: GridPoint) {
        left = left + right
    }
    
    static func -=(left: inout GridPoint, right: GridPoint) {
        left = left - right
    }
}

extension GridPoint: Comparable {
    
    static func < (left: GridPoint, right: GridPoint) -> Bool {
        return left.rawValue < right.rawValue
    }
}

extension GridPoint: Strideable {
    
    func advanced(by n: Int) -> GridPoint {
        return GridPoint(rawValue: rawValue + n)
    }
    
    func distance(to other: GridPoint) -> Int {
        return (other - self).rawValue
    }
}

extension CGFloat {
    init(_ point: GridPoint) {
        self = CGFloat(point.rawValue)
    }
}

extension Float {
    init(_ point: GridPoint) {
        self = Float(point.rawValue)
    }
}

extension Int {
    init(_ point: GridPoint) {
        self = point.rawValue
    }
}

extension CDPoint2 {
    convenience init(x: GridPoint, y: GridPoint) {
        self.init(x: CGFloat(x.rawValue), y: CGFloat(y.rawValue))
    }
}

extension CGPoint {
    init(x: GridPoint, y: GridPoint) {
        self = CGPoint(x: x.rawValue, y: y.rawValue)
    }
}
