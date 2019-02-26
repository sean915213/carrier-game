//
//  float3Extensions.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/29/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import GameKit

extension float3 {
    
    init(point: CGPoint, vertical: Int16 = 0) {
        self.init(Float(point.x), Float(point.y), Float(vertical))
    }
    
    init(point: CDPoint2, vertical: Int16 = 0) {
        self.init(point: point, vertical: Int(vertical))
    }
    
    init(point: CDPoint2, vertical: Int = 0) {
        self.init(Float(point.x), Float(point.y), Float(vertical))
    }
    
    func floored() -> float3 {
        return float3(floor(x), floor(y), floor(z))
    }
}
