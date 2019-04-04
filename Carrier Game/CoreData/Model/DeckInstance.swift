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
import SGYSwiftUtility

class DeckInstance: NSManagedObject {
    
    @NSManaged var blueprint: DeckBlueprint
    @NSManaged var modules: Set<ModuleInstance>
    @NSManaged var ship: ShipInstance
}

extension DeckInstance {
    
    // MARK: - Properties
    
    var moduleBlueprints: [ModuleBlueprint] {
        return modules.map { $0.blueprint }
    }
}

extension DeckInstance {
    
    class func insertNew(into context: NSManagedObjectContext, using blueprint: DeckBlueprint) -> DeckInstance {
        // Make instance
        let deck = DeckInstance.insertNew(into: context)
        deck.blueprint = blueprint
        // Make modules
        for placement in blueprint.modulePlacements {
            let instance = ModuleInstance.insertNew(into: context, using: placement)
            deck.modules.insert(instance)
        }
        return deck
    }
}
