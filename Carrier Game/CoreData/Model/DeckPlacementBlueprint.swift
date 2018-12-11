//
//  DeckPlacementBlueprint.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/5/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData

public class DeckPlacementBlueprint: NSManagedObject {
    
    @NSManaged public var position: Int16
    
    @NSManaged public var blueprint: DeckBlueprint
    @NSManaged public var ship: ShipBlueprint
}
