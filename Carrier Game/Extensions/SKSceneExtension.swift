//
//  SKSceneExtension.swift
//  Carrier Game
//
//  Created by Sean G Young on 2/16/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import Foundation
import SpriteKit

extension SKScene {
    
    func nodes(atViewLocation location: CGPoint) -> [SKNode] {
        // Convert location to scene coords
        let sceneLocation = convertPoint(fromView: location)
        // Return nodes
        return nodes(at: sceneLocation)
    }
}
