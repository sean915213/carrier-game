//
//  ModuleInstance.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/3/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData
import SpriteKit

class ModuleInstance: NSManagedObject {
    
    @NSManaged var placement: ModulePlacement
    @NSManaged var deck: DeckInstance
    @NSManaged var jobs: Set<ModuleJobInstance>
}

extension ModuleInstance {
    
    var blueprint: ModuleBlueprint {
        return placement.blueprint
    }
    
    var absoluteOrigin: GridPoint3 {
        return GridPoint3(placement.origin, Int(deck.placement.position))
    }
    
    var rect: GridRect {
        let size = GridPoint3(placement.blueprint.size, 1)
        return GridRect(origin: absoluteOrigin, size: size)
    }
    
    var absoluteWallCoords: [GridPoint3] {
        return blueprint.wallCoords.map({ GridPoint3(placement.origin, Int(deck.placement.position)) + $0 })
    }
    
    func absolutePoint(fromRelative point: CDPoint2) -> GridPoint3 {
        return absoluteOrigin + GridPoint3(point, 0)
    }
}

extension ModuleInstance {
    class func insertNew(into context: NSManagedObjectContext, using placement: ModulePlacement) -> ModuleInstance {
        // Make instance
        let module = ModuleInstance.insertNew(into: context)
        module.placement = placement
        // Create job instances
        for blueprint in placement.blueprint.jobs {
            let job = ModuleJobInstance.insertNew(into: context)
            job.blueprint = blueprint
            module.jobs.insert(job)
        }
        return module
    }
}
