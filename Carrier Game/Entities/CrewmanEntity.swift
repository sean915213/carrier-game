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
    
    init(crewman: CrewmanInstance, ship: ShipEntity) {
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
    unowned let ship: ShipEntity
    private(set) var status: Status = .idle
    
    private lazy var logger = Logger(source: "Crewman (\(instance.name))")
    
    var rootNode: SKNode {
        return component(ofType: GKSKNodeComponent.self)!.node
    }
    
    var graphNode: GKGridGraphNode3D {
        return ship.graph.node(atPoint: GridPoint3(rootNode.position, GridPoint(currentDeck.instance.placement.position)))!
    }
    
    var currentDeck: DeckEntity {
        return ship.deckEntities.first(where: { $0.instance.placement.position == Int16(instance.position.z) })!
    }
    
    var currentModule: ModuleEntity {
        // Find module crewman is in
        return currentDeck.moduleEntities.first(where: { module -> Bool in
            return module.instance.absoluteRect.contains(GridPoint3(instance.position))
        })!
    }
    
    var movementComponent: MovementComponentProtocol {
        return components.first(where: { $0 is MovementComponentProtocol }) as! MovementComponentProtocol
    }
    
    var isOnShift: Bool {
        return CrewmanShift(date: ship.instance.time) == instance.shift
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
        updateState(in: currentModule.instance, deltaTime: seconds)
    }
    
    private func updateNeeds(deltaTime seconds: TimeInterval) {
        // Loop through needs
        for crewmanNeed in instance.needs {
            // Find all matching needs that current module fulfills
            let fulfilledNeeds = currentModule.instance.blueprint.fulfilledNeeds.filter { $0.action == crewmanNeed.action }
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
    
    private func updateState(in module: ModuleInstance, deltaTime seconds: TimeInterval) {
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
            // - WORKING
            // Get job
            guard let job = instance.job else {
                // TODO: Implement logic for finding new job
                fatalError("Crewman without pre-assigned job not implemented.")
            }
            logger.logInfo("Beginning work [\(job.blueprint.action)].)")
            // If current module contains this job then set working and be done
            guard !currentModule.instance.jobs.contains(job) else {
                status = .busy(.work, ship.instance.time)
                return
            }
            // Get module entity with job
            let moduleEntity = ship.moduleEntities.first(where: { $0.instance.jobs.contains(job) })!
            // Get path to job module
            guard let jobInfo = findClosestEntrance(in: [moduleEntity]) else {
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
        } else {
            // - NEEDS
            // Find module that will satisfy lowest need
            let lowestNeed = instance.needs.min(by: { (need1, need2) -> Bool in
                return need1.value < need2.value
            })!
            let satisfyingModules = ship.moduleEntities.filter { module -> Bool in
                return module.instance.blueprint.fulfilledNeeds.contains(where: { $0.action == lowestNeed.action })
            }
            // If this contains our current module then set to busy
            guard !satisfyingModules.contains(currentModule) else {
                status = .busy(.need(lowestNeed), ship.instance.time)
                return
            }
            // Get closest path to a satisfying module
            guard let entranceInfo = findClosestEntrance(in: satisfyingModules) else {
                fatalError("Could not get path module. Implement this.")
            }
            logger.logInfo("Moving to need [current: \(lowestNeed.value)] in module: \(entranceInfo.module.instance.blueprint.identifier).)")
            // Set to moving
            status = .moving(.need(lowestNeed))
            // Move to module and set status when completed
            movementComponent.setPath(nodes: entranceInfo.path) { result in
                // Set to idle
                // NOTE: Do not set idle if interrupted- this means we had something better to do and will result in this state change overriding the state set for the new 'mission'
                if result != .interrupted { self.status = .idle }
            }
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
            // TODO: RE-IMPLEMENT
            // If need is no longer priority, then move to idle to choose new need
//            else if need != getPriorityNeed() { status = .idle }
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
            guard ship.instance.time.timeIntervalSince(startTime) >= minimumNeedTime else {
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
    
    private func getPriorityNeed() -> CrewmanNeed? {
        // TODO: Get most important need
        fatalError("Not implemented.")
    }
    
    private func performMeander() {
        // If active movement (which should be a previous meander) then skip
        if movementComponent.path != nil { return }
        // Find a random coordinate within this module
        let rect = currentModule.instance.absoluteRect
        let xCoord = rect.xRange.randomElement()!
        let yCoord = rect.yRange.randomElement()!
        // Check for open node here
        guard let node = ship.graph.node(atPoint: GridPoint3(xCoord, yCoord, GridPoint(currentDeck.instance.placement.position))) else {
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
    
    private func findClosestEntrance(in modules: [ModuleEntity]) -> (module: ModuleEntity, entrance: GKGridGraphNode3D, path: [GKGridGraphNode3D])? {
        // Get origin node in graph to prevent finding several times
        let originNode = graphNode
        // Collect distances to entrances
        var distanceInfo = [(module: ModuleEntity, entrance: GKGridGraphNode3D, path: [GKGridGraphNode3D])]()
        for module in modules {
            // ROTATION FIX: Utilize new methods
            let entranceCoords = module.instance.blueprint.entrances.map { module.instance.absolutePoint(fromRelative: $0.coordinate) }
            for entrance in entranceCoords {
                // Get node
                guard let node = ship.graph.node(atPoint: entrance) else {
                    logger.logError("Unable to find node for entrance. Module: \(module.instance.blueprint.name). Entrance: \(entrance).")
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
