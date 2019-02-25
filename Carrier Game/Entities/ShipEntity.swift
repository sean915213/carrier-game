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
    
    init(instance: ShipInstance) {
        self.instance = instance
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let instance: ShipInstance
    
    var blueprint: ShipBlueprint { return instance.blueprint }
    
    private lazy var logger = Logger(source: type(of: self))
    
    // MARK: Entities
    
    private(set) lazy var deckEntities: [DeckEntity] = {
        return blueprint.orderedDecks.map { DeckEntity(blueprint: $0) }
    }()

    private(set) lazy var moduleEntities: [ModuleEntity] = {
        return deckEntities.flatMap { $0.moduleEntities }
    }()

    private(set) lazy var crewmanEntities: [CrewmanEntity] = {
        return instance.crewmen.map { CrewmanEntity(crewman: $0, ship: instance) }
    }()

    var allEntities: [GKEntity] {
        return (deckEntities as [GKEntity]) + (moduleEntities as [GKEntity]) + (crewmanEntities as [GKEntity])
    }
    
    // MARK: - Methods
    
    override func update(deltaTime seconds: TimeInterval) {
        defer { super.update(deltaTime: seconds) }
        // Update time on instance
        
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
