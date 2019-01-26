//
//  DeckInstance.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/3/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData
import SpriteKit
import GameKit
import SGYSwiftUtility

class DeckInstance: NSManagedObject {
    
    @NSManaged var placement: DeckPlacementBlueprint
    @NSManaged var modules: Set<ModuleInstance>
    @NSManaged var ship: ShipInstance
}

extension DeckInstance {
    
    class func insertNew(into context: NSManagedObjectContext, using placement: DeckPlacementBlueprint) -> DeckInstance {
        // Make instance
        let deck = DeckInstance.insertNew(into: context)
        deck.placement = placement
        // Make modules
        for placement in placement.blueprint.modules {
            let instance = ModuleInstance.insertNew(into: context, using: placement)
            deck.modules.insert(instance)
        }
        return deck
    }
    
    var moduleBlueprints: [ModuleBlueprint] {
        return modules.map { $0.blueprint }
    }
    
    func findOpenCoords() -> [GridPoint3] {
        // Map all coords
        let allCoords = Set(modules.flatMap({ $0.absoluteRect.allPoints }))
        // Find open coords
        var openCoords = [GridPoint3]()
        for module in modules {
            for entrance in module.absoluteEntrances {
                let coord = GridPoint3(entrance.coordinate, placement.position)
                // Check for surrounding
                guard allCoords.contains(coord + GridPoint3(-1, 0, 0)) else {
                    openCoords.append(coord)
                    continue
                }
                guard allCoords.contains(coord + GridPoint3(1, 0, 0)) else {
                    openCoords.append(coord)
                    continue
                }
                guard allCoords.contains(coord + GridPoint3(0, 1, 0)) else {
                    openCoords.append(coord)
                    continue
                }
                guard allCoords.contains(coord + GridPoint3(0, -1, 0)) else {
                    openCoords.append(coord)
                    continue
                }
            }
        }
        return openCoords
    }
}
