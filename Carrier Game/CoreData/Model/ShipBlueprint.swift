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
    
    @NSManaged var decks: Set<DeckPlacementBlueprint>
}

extension ShipBlueprint {
    
    var moduleAttributes: [ModuleAttribute: Double] {
        return decks.map({ $0.blueprint }).compactMap({ $0.moduleAttributes }).combined()
    }
}
