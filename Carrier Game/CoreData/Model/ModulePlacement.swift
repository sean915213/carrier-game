//
//  ModulePlacement.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/3/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData

// TODO: NEXT- Is a simple rotation angle added to this class which results in rotating the instance? But that can result in a change of origin- so what would the origin actually be??

// NOTE: This class exists because it's *not* instanced and represents an actual part of the blueprint
class ModulePlacement: NSManagedObject {
    
    @NSManaged var origin: CDPoint2
    @NSManaged var rotation: GridRotation
    
    @NSManaged var blueprint: ModuleBlueprint
    @NSManaged var deck: DeckBlueprint
}
