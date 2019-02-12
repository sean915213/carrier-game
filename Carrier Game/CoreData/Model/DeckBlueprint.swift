//
//  DeckBlueprint.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/3/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData

class DeckBlueprint: NSManagedObject, IdentifiableEntity {
    
    @NSManaged var name: String
    // TODO: REQUIRED ANYMORE?
    @NSManaged var identifier: String
    @NSManaged var position: Int16
    
    @NSManaged var modules: Set<ModulePlacement>
    @NSManaged var ship: ShipBlueprint
}

extension DeckBlueprint {
    
    var moduleAttributes: [ModuleAttribute: Double] {
        return modules.compactMap({ $0.blueprint }).map({ $0.attributes }).combined()
    }
}

extension DeckBlueprint {
    class func insertNew(into context: NSManagedObjectContext, on ship: ShipBlueprint, at position: Int16) -> DeckBlueprint {
        // Make instance
        let deck = DeckBlueprint.insertNew(into: context)
        deck.position = position
        // Add to ship
        ship.decks.insert(deck)
        return deck
    }
}
