//
//  SKNode.swift
//  Carrier Game
//
//  Created by Sean G Young on 2/16/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import Foundation
import SpriteKit

extension SKNode {
    
    enum Name: String {
        case module, texture
    }
}

extension Array where Element: SKNode {
    func withName(_ name: SKNode.Name) -> Array {
        return filter({ $0.name == name.rawValue })
    }
}
