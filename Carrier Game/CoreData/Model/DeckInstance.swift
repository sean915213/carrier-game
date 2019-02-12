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
    
    @NSManaged var blueprint: DeckBlueprint
    @NSManaged var modules: Set<ModuleInstance>
    @NSManaged var ship: ShipInstance
}

extension DeckInstance {
    
    // MARK: - Properties
    
    var moduleBlueprints: [ModuleBlueprint] {
        return modules.map { $0.blueprint }
    }
    
    // MARK: - Methods
    
    func findOpenCoords() -> [GridPoint3] {
        // Map all coords
        let allCoords = Set(modules.flatMap({ $0.placement.absoluteRect.allPoints }))
        // Find open coords
        var openCoords = [GridPoint3]()
        for module in modules {
            for entrance in module.placement.absoluteEntrances {
                // Check for surrounding
                guard allCoords.contains(entrance.coordinate + GridPoint3(-1, 0, 0)) else {
                    openCoords.append(entrance.coordinate)
                    continue
                }
                guard allCoords.contains(entrance.coordinate + GridPoint3(1, 0, 0)) else {
                    openCoords.append(entrance.coordinate)
                    continue
                }
                guard allCoords.contains(entrance.coordinate + GridPoint3(0, 1, 0)) else {
                    openCoords.append(entrance.coordinate)
                    continue
                }
                guard allCoords.contains(entrance.coordinate + GridPoint3(0, -1, 0)) else {
                    openCoords.append(entrance.coordinate)
                    continue
                }
            }
        }
        return openCoords
    }
}

extension DeckInstance {
    class func insertNew(into context: NSManagedObjectContext, using blueprint: DeckBlueprint) -> DeckInstance {
        // Make instance
        let deck = DeckInstance.insertNew(into: context)
        deck.blueprint = blueprint
        // Make modules
        for placement in blueprint.modules {
            let instance = ModuleInstance.insertNew(into: context, using: placement)
            deck.modules.insert(instance)
        }
        return deck
    }
}
