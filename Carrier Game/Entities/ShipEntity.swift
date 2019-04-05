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
    
    private lazy var logger = Logger(source: type(of: self))
    
    // MARK: Entities
    
    private(set) var deckEntities = [DeckEntity]()
    
    var moduleEntities: [ModuleEntity] {
        return deckEntities.flatMap { $0.moduleEntities }
    }

    var crewmanEntities: [CrewmanEntity] {
        // INSTANCE -> BLUEPRINT COMMENTED LOGIC
//        return instance.crewmen.map { CrewmanEntity(crewman: $0, ship: instance) }
        return []
    }

    var allEntities: [GKEntity] {
        return (deckEntities as [GKEntity]) + (moduleEntities as [GKEntity]) + (crewmanEntities as [GKEntity])
    }
    
    // MARK: - Methods
    
    private func setup() {
        for blueprint in blueprint.decks {
            deckEntities.append(DeckEntity(blueprint: blueprint))
        }
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
    
    override func update(deltaTime seconds: TimeInterval) {
        defer { super.update(deltaTime: seconds) }
        // Update time on instance

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

    func deck(at position: Int) -> DeckEntity? {
        return deckEntities.first { $0.blueprint.position == position }
    }
}
