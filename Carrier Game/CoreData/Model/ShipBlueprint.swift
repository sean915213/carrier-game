//
//  ShipBlueprint.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/3/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData

public class ShipBlueprint: NSManagedObject, IdentifiableEntity {
    
    @NSManaged public var identifier: String
    @NSManaged public var name: String
    
    @NSManaged public var decks: Set<DeckPlacementBlueprint>
}
