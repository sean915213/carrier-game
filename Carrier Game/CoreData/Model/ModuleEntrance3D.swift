//
//  ModuleEntrance3D.swift
//  Carrier Game
//
//  Created by Sean G Young on 1/26/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import Foundation

struct ModuleEntrance3D {
    
    let coordinate: GridPoint3
    let zAccess: Bool
}

extension ModuleEntrance3D: CustomDebugStringConvertible {
    var debugDescription: String {
        return String(describing: coordinate) + ", z: \(zAccess)"
    }
}
