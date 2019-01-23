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
        let size = GridPoint3(placement.blueprint.size, 1)
        
        // TODO: DEBUGGING
        let result = GridRect(origin: absoluteOrigin, size: size).rotated(by: placement.rotation, around: .z)
        if result.size.z.rawValue == 0 {
            print("&& WTF LOST SIZE")
        }
        
        return GridRect(origin: absoluteOrigin, size: size).rotated(by: placement.rotation, around: .z)
    }
    
    var absoluteOrigin: GridPoint3 {
        return GridPoint3(placement.origin, Int(deck.placement.position))
    }
    
    var absoluteEntrances: [ModuleEntrance] {
        let rotated: [ModuleEntrance] = blueprint.entrances.map { entrance in
            let translatedEntrance = absolutePoint(fromRelative: entrance.coordinate)
            return ModuleEntrance(coordinate: CDPoint2(x: CGFloat(translatedEntrance.x), y: CGFloat(translatedEntrance.y)), zAccess: entrance.zAccess)
        }
        return rotated
    }
    
    var absoluteWallCoords: [GridPoint3] {
        return blueprint.wallCoords.map({ absolutePoint(fromRelative: $0) })
    }
    
    func absolutePoint(fromRelative point: CDPoint2) -> GridPoint3 {
        return absolutePoint(fromRelative: GridPoint3(point, deck.placement.position))
    }
    
    func absolutePoint(fromRelative point: GridPoint3) -> GridPoint3 {
        return (absoluteOrigin + point).rotated(by: placement.rotation, around: .z)
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
