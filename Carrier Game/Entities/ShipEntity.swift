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
            print("&& SHIFT CHANGE DIFF: \(instance.time.timeIntervalSince(oldDate))")
        }
        super.update(deltaTime: seconds)
    }
    
    // TODO: Is a graph even necessary for path finding? Or can just use origin node instance?
    private func makeGraph() -> GKGridGraph3D<GKGridGraphNode3D> {
        // Collect all nodes from decks
        let nodes = deckEntities.flatMap { $0.graphNodes }
        // Order deck entities by position then drop first deck since it's not needed
        let orderedDecks = deckEntities.sorted(by: \.instance.blueprint.position).dropFirst()
        // Loop through and connect open z-positions that match
        for deck in orderedDecks {
            // Get all module open z-positions
            let openCoords = deck.moduleEntities.flatMap { $0.instance.zEntranceCoords }
            // Loop and make connections
            for coord in openCoords {
                // Find an existing node at the below floor or skip
                guard let belowNode = nodes.first(atPoint: coord - GridPoint3(0, 0, 1)) else {
                    logger.logInfo("No open node found below open z-position: \(coord)")
                    continue
                }
                // Get node for this coord
                let node = nodes.first(atPoint: coord)!
                // Make connection
                node.addConnections(to: [belowNode], bidirectional: true)
            }
        }
        return GKGridGraph3D(nodes)
    }
}
