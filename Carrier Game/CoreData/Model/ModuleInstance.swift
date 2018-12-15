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
    
    var rect: GridRect {
        let origin = GridPoint3(placement.origin, Int(deck.blueprint.position))
        let size = GridPoint3(placement.blueprint.size, 1)
        return GridRect(origin: origin, size: size)
    }
    
    var xyEntranceCoords: [GridPoint3] {
        // Translate all open coords by origin
        let openCoords = blueprint.xyOpenCoords.map { GridPoint3($0 + placement.origin, Int(deck.blueprint.position)) }
        
        // Filter those that open at barriers
        return openCoords.filter { coord in
            if coord.x == rect.xRange.first || coord.x == rect.xRange.last { return true }
            if coord.y == rect.yRange.first || coord.y == rect.yRange.last { return true }
            return false
        }
    }
    
    var zEntranceCoords: [GridPoint3] {
        // All z open coords are entrances to another deck so just map
        return blueprint.zOpenCoords.map { GridPoint3($0 + placement.origin, Int(deck.blueprint.position)) }
    }
    
    var allEntranceCoords: Set<GridPoint3> {
        return Set(xyEntranceCoords + zEntranceCoords)
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
