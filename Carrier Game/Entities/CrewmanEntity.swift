//
//  CrewmanEntity.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/12/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit
import SGYSwiftUtility

// Configurable. May be better way to do this.
private let minimumNeedTime: TimeInterval = (TimeInterval.hour * Double(CrewmanShift.length)) / 2.0 // Currently 1/2 a shift

class CrewmanEntity: GKEntity, StatsProvider {

    enum TargetActivity: Equatable { case need(CrewmanNeed), work }
    
    enum Status: Equatable { case idle, moving(TargetActivity), busy(TargetActivity, Date) }
    
    // MARK: - Initialization
    
    init(crewman: CrewmanInstance, ship: ShipInstance) {
        self.instance = crewman
        self.ship = ship
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let instance: CrewmanInstance
    // TODO: DOES UNOWNED FIX WHAT WOULD BE A REF CYCLE HERE?
    unowned let ship: ShipInstance
    private(set) var status: Status = .idle
    
    private lazy var logger = Logger(source: "Crewman (\(instance.name))")
    
    var rootNode: SKNode {
        return component(ofType: GKSKNodeComponent.self)!.node
    }
    
    var gridPosition: GridPoint3 {
        return GridPoint3(rootNode.position, GridPoint(instance.position.z))
    }
    
    var graphNode: GKGridGraphNode3D {
        return ship.blueprint.graph.node(atPoint: gridPosition)!
    }
    
    var currentDeck: DeckInstance {
        return ship.decks.first(where: { $0.blueprint.position == Int16(instance.position.z) })!
    }
    
    var currentModule: ModuleInstance {
        // Find module crewman is in
        return currentDeck.modules.first(where: { module -> Bool in
            return module.placement.absoluteRect.contains(gridPosition)
        })!
    }
    
    var movementComponent: MovementComponentProtocol {
        return components.first(where: { $0 is MovementComponentProtocol }) as! MovementComponentProtocol
    }
    
    var isOnShift: Bool {
        // Force unwrap because we should not exist unless on a ship instance (vs. blueprint)
        return CrewmanShift(date: ship.time) == instance.shift
    }
    
    // MARK: - Methods
    
    private func setup() {
        // Make components
        // - Node
        let node = SKSpriteNode(color: .red, size: CGSize(width: 1, height: 1))
        node.position = CGPoint(x: CGFloat(instance.position.x), y: CGFloat(instance.position.y))
        let nodeComponent = GKSKNodeComponent(node: node)
        addComponent(nodeComponent)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        // Maintain crewman needs based on what module we're in
        updateNeeds(deltaTime: seconds)
        // Update state
        updateState(deltaTime: seconds)
    }
    
    private func updateNeeds(deltaTime seconds: TimeInterval) {
        // Loop through needs
        for crewmanNeed in instance.needs {
            // Find all matching needs that current module fulfills
            let fulfilledNeeds = currentModule.blueprint.fulfilledNeeds.filter { $0.action == crewmanNeed.action }
            // If none fulfilled then decrement need by decay
            guard !fulfilledNeeds.isEmpty else {
                crewmanNeed.value -= crewmanNeed.decayFactor * seconds
                if crewmanNeed.value < 0 { crewmanNeed.value = 0 }
                continue
            }
            // Increment need by total and factors
            for need in fulfilledNeeds {
                crewmanNeed.value += need.increaseFactor * seconds
                // If >= 100 then set to 100 and reset status to idle
                if crewmanNeed.value >= 100 { crewmanNeed.value = 100 }
            }
        }
    }
    
    private func updateState(deltaTime seconds: TimeInterval) {
        switch status {
        case .idle:
            processIdle()
        case let .moving(activity):
            processMoving(for: activity)
        case let .busy(activity, time):
            processBusy(for: activity, startTime: time)
        }
    }
    
    // MARK: State Logic
    
    private func processIdle() {
        // Check whether on shift
        if isOnShift {
            // WORKING
            performWork()
        } else {
            // NEEDS
            fulfillNextNeed()
        }
    }
    
    private func processMoving(for activity: TargetActivity) {
        switch activity {
        case .need:
            // If now on shift then switch to idle to choose job
            guard !isOnShift else {
                status = .idle
                return
            }
        case .work:
            // If no longer on shift then switch to idle to choose need
            guard isOnShift else {
                status = .idle
                return
            }
        }
    }
    
    private func processBusy(for activity: TargetActivity, startTime: Date) {
        switch activity {
        case let .need(need):
            // If now on shift then switch to idle to choose job
            guard !isOnShift else {
                status = .idle
                return
            }
            // Check whether minimum time spend exceeded
            guard ship.time.timeIntervalSince(startTime) >= minimumNeedTime else {
                return
            }
            // If current need is fulfilled then reset to idle
            guard need.value < 100 else {
                status = .idle
                return
            }
            performMeander()
        case .work:
            // If no longer on shift then switch to idle to choose need
            guard isOnShift else {
                status = .idle
                return
            }
            // TODO: Check whether this is best job? ALSO- check whether this job has too many crewman?
            performMeander()
        }
    }
    
    private func performWork() {
        // Get job
        guard let job = instance.job else {
            // TODO: Implement logic for finding new job
            fatalError("Crewman without pre-assigned job not implemented.")
        }
        logger.logInfo("Beginning work [\(job.blueprint.action)].)")
        // If current module contains this job then set working and be done
        guard !currentModule.jobs.contains(job) else {
            status = .busy(.work, ship.time)
            return
        }
        // Get module entity with job
        let module = ship.allModules.first(where: { $0.jobs.contains(job) })!
        // Get path to job module
        guard let jobInfo = findClosestEntrance(in: [module]) else {
            fatalError("Could not get path module. Implement this.")
        }
        // Update status
        status = .moving(.work)
        // Move to module and set status when completed
        movementComponent.setPath(nodes: jobInfo.path) { result in
            // NOTE: Do not set idle if interrupted- this means we had something better to do and will result in this state change overriding the state set for the new 'mission'
            if result != .interrupted {
                // Return to idle
                self.status = .idle
            }
        }
    }
    
    private func fulfillNextNeed() {
        // Order the needs lowest to highest
        let orderedNeeds = instance.needs.sorted(by: { $0.value < $1.value })
        // Find lowest need that we can move to
        for need in orderedNeeds {
            // Check whether current module could satisfy this need
            guard !currentModule.blueprint.fulfilledNeeds.contains(where: { moduleNeed -> Bool in
                moduleNeed.action == need.action
            }) else {
                status = .busy(.need(need), ship.time)
                return
            }
            // Find modules that would satisfy this need
            let satisfyingModules = ship.allModules.filter { module -> Bool in
                return module.blueprint.fulfilledNeeds.contains(where: { $0.action == need.action })
            }
            // Find the closest entrance we could move to in one of these modules
            guard let entranceInfo = findClosestEntrance(in: satisfyingModules) else {
                // TODO: Logging this results in spam if crewman is stuck in an orphaned module. But should note this somehow?
                continue
            }
            // Set to moving
            status = .moving(.need(need))
            // Move to module and set status when completed
            movementComponent.setPath(nodes: entranceInfo.path) { result in
                // Set to idle
                // NOTE: Do not set idle if interrupted- this means we had something better to do and will result in this state change overriding the state set for the new 'mission'
                if result != .interrupted { self.status = .idle }
            }
            return
        }
    }
    
    private func performMeander() {
        // If active movement (which should be a previous meander) then skip
        if movementComponent.path != nil { return }
        // Find a random coordinate within this module
        let rect = currentModule.placement.absoluteRect
        let xCoord = rect.xRange.randomElement()!
        let yCoord = rect.yRange.randomElement()!
        // Check for open node here
        guard let node = ship.blueprint.graph.node(atPoint: GridPoint3(xCoord, yCoord, GridPoint(currentDeck.blueprint.position))) else {
            return
        }
        // Find path
        let meanderPath = graphNode.findPath(to: node) as! [GKGridGraphNode3D]
        // If empty then no path (which probably should not happen?)
        guard !meanderPath.isEmpty else {
            logger.logError("Found empty meander path. Why would an orphaned graph node exist? Origin: \(graphNode). Destination: \(node)")
            return
        }
        // Assign on movement component
        movementComponent.setPath(nodes: meanderPath, completed: nil)
    }
    
    // MARK: Pathing
    
    private func findClosestEntrance(in modules: [ModuleInstance]) -> (module: ModuleInstance, entrance: GKGridGraphNode3D, path: [GKGridGraphNode3D])? {
        // Get origin node in graph to prevent finding several times
        let originNode = graphNode
        // Collect distances to entrances
        var distanceInfo = [(module: ModuleInstance, entrance: GKGridGraphNode3D, path: [GKGridGraphNode3D])]()
        for module in modules {
            let entranceCoords = module.placement.absoluteEntrances.map { $0.coordinate }
            for entrance in entranceCoords {
                // Get node
                guard let node = ship.blueprint.graph.node(atPoint: entrance) else {
                    logger.logError("Unable to find node for entrance. Module: \(module.blueprint.name). Entrance: \(entrance).")
                    continue
                }
                // Get path
                let path = originNode.findPath(to: node) as! [GKGridGraphNode3D]
                // If empty then path doesn't exist
                guard !path.isEmpty else { continue }
                // Append info
                distanceInfo.append((module: module, entrance: node, path: path))
            }
        }
        // Get shortest entrance
        guard let closestInfo = distanceInfo.min(by: { (info1, info2) -> Bool in
            return info1.path.count < info2.path.count
        }) else {
            return nil
        }
        // Return result with path mapped to float3
        return closestInfo
    }
    
    // MARK: StatsProvider Implementation
    
    func provideStats() -> (name: String, stats: [Stat]) {
        let stats = instance.needs.map { return Stat(name: String(describing: $0.action), value: $0.value) }
        return (instance.name, stats)
    }
}
