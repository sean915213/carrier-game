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
        let origin: int3 = [Int32(placement.origin.x), Int32(placement.origin.y), Int32(deck.blueprint.position)]
        let size: int3 = [Int32(placement.blueprint.size.x), Int32(placement.blueprint.size.y), 1]
        return GridRect(origin: origin, size: size)
    }
    
//    var rect: CGRect {
//        return CGRect(x: placement.origin.x, y: placement.origin.y, width: CGFloat(placement.blueprint.size.x), height: CGFloat(placement.blueprint.size.y))
//    }
    
    var xyEntranceCoords: [float3] {
        // Translate all open coords by origin
        let openCoords = blueprint.xyOpenCoords.map { float3(point: $0 + placement.origin, vertical: deck.blueprint.position) }
        let gridRect = GridRect(origin: [Int32(placement.origin.x), Int32(placement.origin.y), Int32(deck.blueprint.position)], size: [Int32(placement.blueprint.size.x), Int32(placement.blueprint.size.y), 1])
        // Filter those that open at barriers
        return openCoords.filter { coord in
            if Int32(coord.x) == gridRect.xRange.first || Int32(coord.x) == gridRect.xRange.last { return true }
            if Int32(coord.y) == gridRect.yRange.first || Int32(coord.y) == gridRect.yRange.last { return true }
            return false
        }
    }
    
//    var xyEntranceCoords: [float3] {
//        // Translate all open coords by origin
//        let openCoords = blueprint.xyOpenCoords.map { float3(point: $0 + placement.origin, vertical: deck.blueprint.position) }
//        // Filter those that open at barriers
//        return openCoords.filter { coord in
//            if CGFloat(coord.x) == rect.minX || CGFloat(coord.x) == (rect.maxX - 1) { return true }
//            if CGFloat(coord.y) == rect.minY || CGFloat(coord.y) == (rect.maxY - 1) { return true }
//            return false
//        }
//    }
    
    var zEntranceCoords: [float3] {
        // All z open coords are entrances to another deck so just map
        return blueprint.zOpenCoords.map { float3(point: $0 + placement.origin, vertical: deck.blueprint.position) }
    }
    
    var allEntranceCoords: Set<float3> {
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
