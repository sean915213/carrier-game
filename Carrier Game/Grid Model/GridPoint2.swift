//
//  GridPoint2.swift
//  Carrier Game
//
//  Created by Sean G Young on 2/15/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import Foundation
import GameplayKit

// Defined because our grid points are specific and typealiasing int3 wasn't enough.
struct GridPoint2: Hashable, Equatable {
    
    static let zero = GridPoint2(0, 0)
    
    init(_ point: CDPoint2) {
        self.init(GridPoint(point.x), GridPoint(point.y))
    }
    
    init(_ x: Int, _ y: Int) {
        self.init(GridPoint(x), GridPoint(y))
    }
    
    init(_ x: GridPoint, _ y: GridPoint) {
        self.x = x
        self.y = y
    }
    
    var x: GridPoint
    var y: GridPoint
}

extension GridPoint2 {
    
    static func +(left: GridPoint2, right: GridPoint2) -> GridPoint2 {
        return GridPoint2(left.x + right.x, left.y + right.y)
    }
    
    static func -(left: GridPoint2, right: GridPoint2) -> GridPoint2 {
        return GridPoint2(left.x - right.x, left.y - right.y)
    }
    
    static func +=(left: inout GridPoint2, right: GridPoint2) {
        left = left + right
    }
    
    static func -=(left: inout GridPoint2, right: GridPoint2) {
        left = left - right
    }
}
