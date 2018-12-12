//
//  DeckPlacementBlueprint.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/5/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData

class DeckPlacementBlueprint: NSManagedObject {
    
    @NSManaged var position: Int16
    
    @NSManaged var blueprint: DeckBlueprint
    @NSManaged var ship: ShipBlueprint
}
