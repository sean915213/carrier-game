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
    
    func placeModule(withIdentifier identifier: String, at origin: CDPoint2) throws -> ModuleInstance {
        let placement = try blueprint.placeModule(withIdentifier: identifier, at: origin)
        return placeModule(withPlacement: placement)
    }
    
    func placeModule(_ module: ModuleBlueprint, at origin: CDPoint2) -> ModuleInstance {
        let placement = blueprint.placeModule(module, at: origin)
        return placeModule(withPlacement: placement)
    }
    
    private func placeModule(withPlacement placement: ModulePlacement) -> ModuleInstance {
        // Insert a new module placement into our current context
        guard let context = managedObjectContext else { fatalError("Attempt to place a module on a DeckInstance with no associated context.") }
        // Create an instance
        let instance = ModuleInstance.insertNew(into: context, using: placement)
        // Add to our set and return
        modules.insert(instance)
        return instance
    }
}
