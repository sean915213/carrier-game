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
    
    @NSManaged var modulePlacements: Set<ModulePlacement>
    @NSManaged var ship: ShipBlueprint
}

extension DeckBlueprint {

    // MARK: - Properties
    
    var moduleAttributes: [ModuleAttribute: Double] {
        return modulePlacements.compactMap({ $0.blueprint }).map({ $0.attributes }).combined()
    }
    
    // MARK: - Methods
    
    func makeGraph() -> GKGridGraph3D<GKGridGraphNode3D> {
        // Make graph and connect individual module graphs
        let graph = GKGridGraph3D([])
        for module in modulePlacements {
            graph.addGraph(module.makeGraph(), connectAdjacentNodes: true)
        }
        return graph
    }
    
    func findOpenPoints() -> [GridPoint2] {
        // Map all coords
        let allCoords = Set(modulePlacements.flatMap({ $0.absoluteRect.allPoints }))
        // Find open coords
        var openCoords = [GridPoint2]()
        let addPoint = { (point: GridPoint3) in openCoords.append(GridPoint2(point.x, point.y)) }
        for module in modulePlacements {
            for entrance in module.absoluteEntrances {
                // Check for surrounding
                guard allCoords.contains(entrance.coordinate + GridPoint3(-1, 0, 0)) else {
                    addPoint(entrance.coordinate)
                    continue
                }
                guard allCoords.contains(entrance.coordinate + GridPoint3(1, 0, 0)) else {
                    addPoint(entrance.coordinate)
                    continue
                }
                guard allCoords.contains(entrance.coordinate + GridPoint3(0, 1, 0)) else {
                    addPoint(entrance.coordinate)
                    continue
                }
                guard allCoords.contains(entrance.coordinate + GridPoint3(0, -1, 0)) else {
                    addPoint(entrance.coordinate)
                    continue
                }
            }
        }
        return openCoords
    }
    
    func findOverlappingPoints() -> Set<GridPoint2> {
        // Collect points into a set
        var modulePoints = Set<GridPoint2>()
        var invalidPoints = Set<GridPoint2>()
        for placement in modulePlacements {
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
    
    enum PlacementError: Error { case notFound }
    
    class func insertNew(into context: NSManagedObjectContext, on ship: ShipBlueprint, at position: Int16) -> DeckBlueprint {
        // Make instance
        let deck = DeckBlueprint(context: context)
        deck.position = position
        // Add to ship
        ship.decks.insert(deck)
        return deck
    }
    
    @discardableResult
    func placeModule(withIdentifier identifier: String, at origin: CDPoint2) throws -> ModulePlacement {
        // Insert a new module placement into our current context
        guard let context = managedObjectContext else { fatalError("Attempt to place a module on a DeckBlueprint with no associated context.") }
        // Retrieve module
        guard let module = try ModuleBlueprint.entityWithIdentifier(identifier, using: context) else { throw PlacementError.notFound }
        // Place
        return placeModule(module, at: origin)
    }
    
    @discardableResult
    func placeModule(_ module: ModuleBlueprint, at origin: CDPoint2) -> ModulePlacement {
        // Insert a new module placement into our current context
        guard let context = managedObjectContext else { fatalError("Attempt to place a module on a DeckBlueprint with no associated context.") }
        let placement = ModulePlacement(context: context)
        placement.blueprint = module
        placement.origin = origin
        // Add to our list and return
        modulePlacements.insert(placement)
        return placement
    }
}
