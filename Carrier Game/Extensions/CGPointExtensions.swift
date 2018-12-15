//
//  CGPointExtensions.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/6/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreGraphics
import GameplayKit

extension CGPoint {
    
    init(_ vector: vector_int2) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }
}

extension CGPoint {
    
    static func +(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func -(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    static func +=(left: inout CGPoint, right: CGPoint) {
        left = left + right
    }
    
    static func -=(left: inout CGPoint, right: CGPoint) {
        left = left - right
    }
}
