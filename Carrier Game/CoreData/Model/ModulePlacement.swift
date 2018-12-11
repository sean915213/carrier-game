//
//  ModulePlacement.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/3/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData

// NOTE: This class exists because it's *not* instanced and represents an actual part of the blueprint
public class ModulePlacement: NSManagedObject {
    
    @NSManaged var origin: CDPoint2
    
    @NSManaged var blueprint: ModuleBlueprint
    @NSManaged var deck: DeckBlueprint
}
