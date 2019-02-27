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
class ModulePlacement: NSManagedObject {
    
    @NSManaged var origin: CDPoint2
    @NSManaged var rotation: GridRotation
    
    @NSManaged var blueprint: ModuleBlueprint
    @NSManaged var deck: DeckBlueprint
    
    @NSManaged var instances: Set<ModuleInstance>
}

extension ModulePlacement {
    
    // MARK: - Properties

    var absoluteRect: GridRect {
        let size = GridPoint3(blueprint.size, 1)
        return GridRect(origin: absoluteOrigin, size: size).rotated(by: rotation, around: .z)
    }

    var absoluteOrigin: GridPoint3 {
        return GridPoint3(origin, Int(deck.position))
    }

    var absoluteEntrances: [ModuleEntrance3D] {
        return blueprint.entrances.map { entrance in
            let translatedCoord = absolutePoint(fromRelative: GridPoint2(entrance.coordinate))
            return ModuleEntrance3D(coordinate: translatedCoord, zAccess: entrance.zAccess)
        }
    }

    var absoluteWallCoords: [GridPoint3] {
        return blueprint.wallCoords.map({ absolutePoint(fromRelative: GridPoint2($0)) })
    }

    // MARK: - Methods
    
    func makeGraph() -> GKGridGraph3D<GKGridGraphNode3D> {
        let wallCoords = Set(absoluteWallCoords)
        // Make graph and add nodes
        let graph = GKGridGraph3D([])
        for coord in absoluteRect.allPoints {
            guard !wallCoords.contains(coord) else { continue }
            graph.connectToAdjacentNodes(GKGridGraphNode3D(point: coord))
        }
        return graph
    }

    func absolutePoint(fromRelative point: GridPoint2) -> GridPoint3 {
        return absolutePoint(fromRelative: GridPoint3(point, deck.position))
    }

    func absolutePoint(fromRelative point: GridPoint3) -> GridPoint3 {
        // Be safe
        assert(point.z == absoluteOrigin.z, "Point outside containing deck's bounds.")
        // Rotations are linear so easiest thing to do is rotate *first* around relative origin (zero), then translate by x & y
        return point.rotated(by: rotation, around: .z, origin: .zero) + GridPoint3(origin, 0)
    }
}
