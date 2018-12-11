//
//  DeckInstance.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/3/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData
import SpriteKit
import GameKit

class DeckInstance: NSManagedObject {
    
    @NSManaged var blueprint: DeckPlacementBlueprint
    @NSManaged var modules: Set<ModuleInstance>
    @NSManaged var ship: ShipInstance
}

extension DeckInstance {
    
    class func insertNew(into context: NSManagedObjectContext, using placement: DeckPlacementBlueprint) -> DeckInstance {
        // Make instance
        let deck = DeckInstance.insertNew(into: context)
        deck.blueprint = placement
        // Make modules
        for placement in placement.blueprint.modules {
            let instance = ModuleInstance.insertNew(into: context, using: placement)
            deck.modules.insert(instance)
        }
        return deck
    }
    
    var moduleBlueprints: [ModuleBlueprint] {
        return modules.map { $0.blueprint }
    }
}
