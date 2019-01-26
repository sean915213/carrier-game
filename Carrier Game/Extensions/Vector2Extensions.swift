//
//  Vector2Extensions.swift
//  Carrier Game
//
//  Created by Sean G Young on 10/17/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import SpriteKit

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
