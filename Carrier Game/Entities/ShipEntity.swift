//
//  ShipEntity.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/27/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit
import GameplayKit
import SGYSwiftUtility

// TODO: POSITIONING ALL FUCKED UP AFTER ROTATIONS.
// NEXT: Wall sprite placement is fucked up after rotation implementation.
// THEN: First solution is to make sure all non-instance classes are producing GridPoint3. This fucks up intuitive math operations since they must assign arbitrariy z-position.

class ShipEntity: GKEntity {

    // MARK: - Initialization
    
    init(ship: ShipInstance) {
        self.instance = ship
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let instance: ShipInstance
    
    private lazy var logger = Logger(source: type(of: self))
    
    // MARK: Entities
    
    private(set) lazy var deckEntities: [DeckEntity] = {
        return instance.orderedDecks.map { DeckEntity(deck: $0) }
    }()
    
    private(set) lazy var moduleEntities: [ModuleEntity] = {
        return deckEntities.flatMap { $0.moduleEntities }
    }()
    
    private(set) lazy var crewmanEntities: [CrewmanEntity] = {
        return instance.crewmen.map { CrewmanEntity(crewman: $0, ship: self) }
    }()
    
    private(set) lazy var allEntities: [GKEntity] = {
        return (deckEntities as [GKEntity]) + (moduleEntities as [GKEntity]) + (crewmanEntities as [GKEntity])
    }()
    
    private(set) lazy var graph: GKGridGraph3D<GKGridGraphNode3D> = {
        return makeGraph()
    }()
    
    // MARK: - Methods
    
    override func update(deltaTime seconds: TimeInterval) {
        let oldShift = CrewmanShift(date: instance.time)!
        let oldDate = instance.time
        
        instance.time = instance.time.addingTimeInterval(seconds)
        
        // Log new shift
        let newShift = CrewmanShift(date: instance.time)!
        if newShift != oldShift {
            logger.logInfo("New shift: \(newShift).")
        }
        super.update(deltaTime: seconds)
    }
    
    private func makeGraph() -> GKGridGraph3D<GKGridGraphNode3D> {
        // Main graph
        let shipGraph = GKGridGraph3D<GKGridGraphNode3D>([])
        // Order deck entities by position
        let orderedDecks = deckEntities.sorted(by: \.instance.placement.position)
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
            for module in deck.moduleEntities {
                for entrance in module.instance.absoluteEntrances {
                    guard entrance.zAccess else { continue }
                    let entranceCoord = GridPoint3(entrance.coordinate, deck.instance.placement.position)
                    zCoords.append(entranceCoord)
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

extension ShipEntity {
    
    func deck(at position: Int) -> DeckEntity? {
        return deckEntities.first { $0.instance.placement.position == position }
    }
}
