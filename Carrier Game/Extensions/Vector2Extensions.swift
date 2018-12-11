//
//  Vector2Extensions.swift
//  Carrier Game
//
//  Created by Sean G Young on 10/17/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import SpriteKit

// TODO: Wasn't working?
//extension vector_int2 {
//    init(x: Int, y: Int) {
//        self.init(Int32(x), Int32(y))
//    }
//}

extension vector_int2 {
    init(_ point: CGPoint) {
        self.init(Int32(point.x), Int32(point.y))
    }
}

extension vector_int2 {
    static let zero = vector_int2()
}

extension vector_int2: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}



//func +(left: vector_int2, right: vector_int2) -> vector_int2 {
//    
//    
//    
//    
//    
//    // 1
//    var sum = [Int]() // 2
//    assert(left.count == right.count, "vector of same length only")  // 3
//    for (key, v) in enumerate(left) {
//        sum.append(left[key] + right[key]) // 4
//    }
//    return sum
//}
