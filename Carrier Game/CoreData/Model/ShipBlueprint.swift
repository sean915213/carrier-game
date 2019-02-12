//
//  ShipBlueprint.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/3/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData

class ShipBlueprint: NSManagedObject, IdentifiableEntity {
    
    @NSManaged var identifier: String
    @NSManaged var name: String
    
    @NSManaged var decks: Set<DeckBlueprint>
}

extension ShipBlueprint {
    
    var orderedDecks: [DeckBlueprint] {
        return decks.sorted { (deck1, deck2) -> Bool in
            return deck1.position < deck2.position
        }
    }
    
    var moduleAttributes: [ModuleAttribute: Double] {
        return decks.compactMap({ $0.moduleAttributes }).combined()
    }
}
