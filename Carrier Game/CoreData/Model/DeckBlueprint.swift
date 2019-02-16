//
//  DeckBlueprint.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/3/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData

class DeckBlueprint: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var position: Int16
    
    // TODO: Rename to modulePlacements
    @NSManaged var modules: Set<ModulePlacement>
    @NSManaged var ship: ShipBlueprint
}

extension DeckBlueprint {
    
    struct ValidationConditions: OptionSet {
        let rawValue: Int
        
        static let modulePlacements = ValidationConditions(rawValue: 1 << 0)
        static let bounds = ValidationConditions(rawValue: 1 << 1)
    }
    
    // MARK: - Properties
    
    var moduleAttributes: [ModuleAttribute: Double] {
        return modules.compactMap({ $0.blueprint }).map({ $0.attributes }).combined()
    }
    
    // MARK: - Methods
    
    func makeGraph() -> GKGridGraph3D<GKGridGraphNode3D> {
        // Make graph and connect individual module graphs
        let graph = GKGridGraph3D([])
        for module in modules {
            graph.addGraph(module.makeGraph(), connectAdjacentNodes: true)
        }
        return graph
    }
    
    // TODO: Return type definitely needs fleshed out when validating more than overlapping points
    func validate(conditions: ValidationConditions) -> Set<GridPoint2> {
        // Collect points into a set
        var modulePoints = Set<GridPoint2>()
        var invalidPoints = Set<GridPoint2>()
        for placement in modules {
            for point in placement.absoluteRect.allPoints {
                let gridPoint = GridPoint2(point.x, point.y)
                // If already in set then there's an overlap
                if modulePoints.contains(gridPoint) {
                    invalidPoints.insert(gridPoint)
                } else {
                    modulePoints.insert(gridPoint)
                }
            }
        }
        return invalidPoints
    }
}

extension DeckBlueprint {
    class func insertNew(into context: NSManagedObjectContext, on ship: ShipBlueprint, at position: Int16) -> DeckBlueprint {
        // Make instance
        let deck = DeckBlueprint.insertNew(into: context)
        deck.position = position
        // Add to ship
        ship.decks.insert(deck)
        return deck
    }
}
