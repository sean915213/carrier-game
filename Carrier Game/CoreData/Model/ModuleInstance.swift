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
    
    // MARK: - Properties
    
    var blueprint: ModuleBlueprint {
        return placement.blueprint
    }
    
    var absoluteRect: GridRect {
        let size = GridPoint3(placement.blueprint.size, 1)
        return GridRect(origin: absoluteOrigin, size: size).rotated(by: placement.rotation, around: .z)
    }
    
    var absoluteOrigin: GridPoint3 {
        return GridPoint3(placement.origin, Int(deck.blueprint.position))
    }
    
    var absoluteEntrances: [ModuleEntrance3D] {
        return blueprint.entrances.map { entrance in
            let translatedCoord = absolutePoint(fromRelative: entrance.coordinate)
            return ModuleEntrance3D(coordinate: translatedCoord, zAccess: entrance.zAccess)
        }
    }
    
    var absoluteWallCoords: [GridPoint3] {
        return blueprint.wallCoords.map({ absolutePoint(fromRelative: $0) })
    }
    
    // MARK: - Methods
    
    func absolutePoint(fromRelative point: CDPoint2) -> GridPoint3 {
        return absolutePoint(fromRelative: GridPoint3(point, deck.blueprint.position))
    }
    
    func absolutePoint(fromRelative point: GridPoint3) -> GridPoint3 {
        // Be safe
        assert(point.z == absoluteOrigin.z, "Point outside containing deck's bounds.")
        // Rotations are linear so easiest thing to do is rotate *first* around relative origin (zero), then translate by x & y
        return point.rotated(by: placement.rotation, around: .z, origin: .zero) + GridPoint3(placement.origin, 0)
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
