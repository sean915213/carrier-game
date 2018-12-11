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
