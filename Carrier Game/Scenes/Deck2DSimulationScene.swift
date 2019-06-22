//
//  Deck2DSimulationScene.swift
//  Carrier Game
//
//  Created by Sean G Young on 4/4/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit

class Deck2DSimulationScene: BaseDeck2DScene {
    
    // MARK: - Initialization
    
    init(ship: ShipInstance, size: CGSize) {
        self.shipInstance = ship
        super.init(ship: ship.blueprint, size: size)
        // Assign instance to our entity
        shipEntity.setShipInstance(ship)
        configureScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let shipInstance: ShipInstance
    
    private(set) lazy var reporter = StatReportingEntity()
    
    private var lastUpdate: TimeInterval?
    
    var enableSimulation: Bool = true {
        didSet { updateSimulationEnabled() }
    }
    
    // MARK: - Methods
    
    private func configureScene() {
        // Add existing crewmen to scene
        shipEntity.crewmanEntities.forEach { addCrewman($0) }
    }
    
    private func addCrewman(_ entity: CrewmanEntity) {
        // Add 2D movement components for this scene
        entity.addComponent(MovementComponent2D())
        // Add node to scene
        // NOTE: crewman nodes are always added regardless of the deck they're on because they hide/unhide themselves based on this fact. Keeping the nodes on scene helps time their movement on invisible decks.
        addChild(entity.rootNode)
        // TODO: FIGURE THIS OUT
        // Raise z on crewman node
        entity.rootNode.zPosition = 100
    }

    private func updateSimulationEnabled() {
        // Currently only need to pause actions on crewmen
        for crewman in shipEntity.crewmanEntities {
            crewman.rootNode.isPaused = !enableSimulation
        }
    }
    
    override func displayDeck(entity: DeckEntity) {
        super.displayDeck(entity: entity)
        // Update all crewman's movement component
        for crewman in shipEntity.crewmanEntities {
            let component = crewman.component(ofType: MovementComponent2D.self)!
            component.visibleVertical = GridPoint(entity.blueprint.position)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        // Always update
        defer { lastUpdate = currentTime }
        // Get last time or set to this time and wait until update
        guard let lastTimeUpdate = lastUpdate else { return }
        // If simulation not enabled do nothing else
        guard enableSimulation else { return }
        // Get game-seconds update from our game seconds factor
        let dtGame = (currentTime - lastTimeUpdate) * Configuration.gameSecondsPerRealSecond
        // Apply to entities
        // - SHIP
        shipEntity.update(deltaTime: dtGame)
        // - STAT REPORTER
        reporter.update(deltaTime: dtGame)
    }
}
