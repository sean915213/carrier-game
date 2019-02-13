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
    
    init(blueprint: ShipBlueprint) {
        self.blueprint = blueprint
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let blueprint: ShipBlueprint
    
    var instance: ShipInstance? {
        didSet {
            // TODO: Does this ignore saved values for crewmen?
            if let ship = instance {
                let entities = ship.crewmen.map { CrewmanEntity(crewman: $0, ship: ship) }
                crewmanEntities.append(contentsOf: entities)
            } else {
                crewmanEntities.removeAll()
            }
        }
    }
    
    private lazy var logger = Logger(source: type(of: self))
    
    // MARK: Entities
    
    private(set) lazy var deckEntities: [DeckEntity] = {
        return blueprint.orderedDecks.map { DeckEntity(blueprint: $0) }
    }()
    
    private(set) lazy var moduleEntities: [ModuleEntity] = {
        return deckEntities.flatMap { $0.moduleEntities }
    }()
    
    private(set) var crewmanEntities = [CrewmanEntity]()
    
    var allEntities: [GKEntity] {
        return (deckEntities as [GKEntity]) + (moduleEntities as [GKEntity]) + (crewmanEntities as [GKEntity])
    }
    
    // MARK: - Methods
    
    override func update(deltaTime seconds: TimeInterval) {
        defer { super.update(deltaTime: seconds) }
        // Nothing to do if no instance assigned
        guard let instance = instance else { return }
        // Update
        
        let oldShift = CrewmanShift(date: instance.time)!
        instance.time = instance.time.addingTimeInterval(seconds)
        // Log new shift
        let newShift = CrewmanShift(date: instance.time)!
        if newShift != oldShift {
            logger.logInfo("New shift: \(newShift).")
        }
    }
}

extension ShipEntity {
    
    func deck(at position: Int) -> DeckEntity? {
        return deckEntities.first { $0.blueprint.position == position }
    }
}
