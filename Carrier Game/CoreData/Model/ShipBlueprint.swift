//
//  ShipBlueprint.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/3/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData
import SGYSwiftUtility

class ShipBlueprint: NSManagedObject, IdentifiableEntity {
    
    @NSManaged var identifier: String
    @NSManaged var name: String
    
    @NSManaged var decks: Set<DeckBlueprint>
    
    private lazy var logger = Logger(source: type(of: self))
    
    private(set) lazy var graph: GKGridGraph3D<GKGridGraphNode3D> = {
        return makeGraph()
    }()
}

extension ShipBlueprint {
    
    var orderedDecks: [DeckBlueprint] {
        return decks.sorted { (deck1, deck2) -> Bool in
            return deck1.position < deck2.position
        }
    }
    
    var moduleAttributes: [ModuleAttribute: Double] {
        return decks.compactMap({ $0.moduleAttributes }).combined()
    }
    
    private func makeGraph() -> GKGridGraph3D<GKGridGraphNode3D> {
        // Main graph
        let shipGraph = GKGridGraph3D<GKGridGraphNode3D>([])
        // Loop
        for deck in orderedDecks {
            // Make graph
            let deckGraph = deck.makeGraph()
            // Add to main graph without connections
            shipGraph.addGraph(deckGraph, connectAdjacentNodes: false)
            // If this is first deck then there cannot be z connections so skip
            guard deck != orderedDecks.first else { continue }
            // Get all module entrances with z-access
            var zCoords = [GridPoint3]()
            for modulePlacement in deck.modulePlacements {
                for entrance in modulePlacement.absoluteEntrances {
                    guard entrance.zAccess else { continue }
                    zCoords.append(entrance.coordinate)
                }
            }
            // Loop and make connections
            for coord in zCoords {
                guard let node = deckGraph.node(atPoint: coord) else {
                    fatalError("No existing node mapped for entrance coord with z-access.")
                }
                // Find an existing node at the below floor or skip
                guard let openZBelowNode = shipGraph.node(atPoint: coord - GridPoint3(0, 0, 1)) else {
                    logger.logInfo("No open node found below open z-position: \(coord)")
                    continue
                }
                // Make a z connection
                node.addConnections(to: [openZBelowNode], bidirectional: true)
            }
        }
        return shipGraph
    }
}
