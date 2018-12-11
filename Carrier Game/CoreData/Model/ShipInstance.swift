//
//  ShipInstance.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/3/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData

class ShipInstance: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var time: Date
    
    @NSManaged var blueprint: ShipBlueprint
    @NSManaged var decks: Set<DeckInstance>
    @NSManaged var crewmen: Set<CrewmanInstance>
}

extension ShipInstance {
    
    var orderedDecks: [DeckInstance] {
        return decks.sorted { (deck1, deck2) -> Bool in
            return deck1.blueprint.position < deck2.blueprint.position
        }
    }
    
    var allModules: [ModuleInstance] {
        return decks.flatMap { $0.modules }
    }
}

extension ShipInstance {
    
    class func insertNew(into context: NSManagedObjectContext, using blueprint: ShipBlueprint) -> ShipInstance {
        // Make instance
        let ship = ShipInstance.insertNew(into: context)
        ship.time = Date()
        ship.blueprint = blueprint
        // Make deck instances
        for placement in blueprint.decks {
            let instance = DeckInstance.insertNew(into: context, using: placement)
            ship.decks.insert(instance)
        }
        return ship
    }
    
}
