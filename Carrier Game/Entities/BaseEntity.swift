//
//  BaseEntity.swift
//  Carrier Game
//
//  Created by Sean G Young on 4/2/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit
import GameplayKit

// TODO: How to organize this. Options are using GameplayKit which doesn't seem to fit needs. Or creating our own system of classes which act like a tree of instance > child instance.
// WE'RE AT: Stuck at DeckEntity using ModuleEntity instances. Can't add sub entities. And would that even be useful? We're trying to just *draw* right now for blueprint editing. How do we reuse drawing logic with combinations of no-update logic (blueprint creation) and normal update logic for in game. What handles the module being degraded? A module entity? Or SKNode subclass? SKnode subclass is mixing logic with display though.

class BaseEntity: GKEntity {
    
    lazy var childEntities: [GKEntity] = []
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        childEntities.forEach({ $0.update(deltaTime: seconds) })
    }
}
