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
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let blueprint: ShipBlueprint
    private(set) var instance: ShipInstance?
    
    private lazy var logger = Logger(source: type(of: self))
    
    // MARK: Entities
    
    private(set) var deckEntities = [DeckEntity]()
    private(set) var crewmanEntities = [CrewmanEntity]()
    
    // MARK: - Methods
    
    private func setup() {
        // Create entities for each existing deck
        for blueprint in blueprint.decks {
            deckEntities.append(DeckEntity(blueprint: blueprint))
        }
    }
    
    func setShipInstance(_ newInstance: ShipInstance) {
        assert(instance == nil, "A ShipInstance may only be assigned once.")
        // Assign
        instance = newInstance
        // Add existing crewmen
        for crewman in newInstance.crewmen { addCrewmanEntity(for: crewman) }
    }
    
    @discardableResult
    func addDeckEntity(for blueprint: DeckBlueprint) -> DeckEntity {
        let entity = DeckEntity(blueprint: blueprint)
        deckEntities.append(entity)
        return entity
    }
    
    func removeDeckEntity(_ entity: DeckEntity) {
        guard let index = deckEntities.firstIndex(of: entity) else {
            assertionFailure("Asked to remove deck entity that does not exist in collection.")
            return
        }
        // Remove
        deckEntities.remove(at: index)
    }
    
    @discardableResult
    func addCrewmanEntity(for crewman: CrewmanInstance) -> CrewmanEntity {
        // Be safe
        guard let instance = instance else { fatalError("Cannot add CrewmanEntity without an assigned ShipInstance") }
        // Create and add entity
        let entity = CrewmanEntity(crewman: crewman, ship: instance)
        crewmanEntities.append(entity)
        return entity
    }
    
    func removeCrewmanEntity(_ entity: CrewmanEntity) {
        guard let index = crewmanEntities.firstIndex(of: entity) else {
            assertionFailure("Asked to remove CrewmanEntity that does not exist in collection.")
            return
        }
        // Remove
        crewmanEntities.remove(at: index)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        defer { super.update(deltaTime: seconds) }
        guard let instance = instance else {
            assertionFailure("\(#function) called without an assigned ShipInstance.")
            return
        }
        // Update time on instance
        instance.time = instance.time.addingTimeInterval(seconds)
        // Update on decks and crewmen
        deckEntities.forEach { $0.update(deltaTime: seconds) }
        crewmanEntities.forEach { $0.update(deltaTime: seconds) }

        // INSTANCE -> BLUEPRINT COMMENTED LOGIC
//        let oldShift = CrewmanShift(date: instance.time)!
//        instance.time = instance.time.addingTimeInterval(seconds)
//        // Log new shift
//        let newShift = CrewmanShift(date: instance.time)!
//        if newShift != oldShift {
//            logger.logInfo("New shift: \(newShift).")
//        }
    }
}

extension ShipEntity {
    
    var moduleEntities: [ModuleEntity] {
        return deckEntities.flatMap { $0.moduleEntities }
    }
    
    var allEntities: [GKEntity] {
        return (deckEntities as [GKEntity]) + (moduleEntities as [GKEntity]) + (crewmanEntities as [GKEntity])
    }

    func deck(at position: Int) -> DeckEntity? {
        return deckEntities.first { $0.blueprint.position == position }
    }
}
