//
//  Deck2DSimulationScene.swift
//  Carrier Game
//
//  Created by Sean G Young on 4/4/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit

// TODO LATEST:
// Need to move items with comment "// INSTANCE -> BLUEPRINT COMMENTED LOGIC" to simulation logic vs. editing (static) logic
// Created classes that inherit from the base simulation classes (ie. this one and DeckSimulationViewController). Need to add commented simulation logic to these so that they share the basic functionality (should be done) but also add the necessary simulation logic

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
    
    private var lastUpdate: TimeInterval = 0
    
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
    
    // TODO: Probably not required now since not editing and simulating in the same controllers
//    private func toggleSimulation() {
//        // If simulation disabled (meaning the toggle will reenable) then find crewmen in invalid locations and move them to a random, valid location
//        if !scene.enableSimulation {
//            let gridPositions: [GridPoint3] = ship.graph.gridNodes?.map({ $0.position }) ?? []
//            for crewman in shipEntity.crewmanEntities {
//                // Check whether crewman's current position is still valid
//                guard !gridPositions.contains(GridPoint3(crewman.instance.position)) else { continue }
//                // Find a random node
//                let position = gridPositions.randomElement()!
//                // Assign crewman's position here
//                crewman.movementComponent.setPosition(position)
//            }
//        }
//        // Reenable simulation and re-configure toolbar
//        scene.enableSimulation.toggle()
//    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        // If simulation not enabled then do nothing
        guard enableSimulation else { return }
        // Save this update
        defer { lastUpdate = currentTime }
        // If lastUpdate is 0 then do nothing yet
        guard lastUpdate != 0 else { return }
        // Get real-time difference
        let dt = currentTime - lastUpdate
        // Convert to game time delta
        let gameDT = dt * ((60 * 60) / 3.0) * 2
        // Apply to ship instance
        shipEntity.update(deltaTime: gameDT)
        // Update on stat reporter AFTER ship entity updates
        reporter.update(deltaTime: gameDT)
    }
}