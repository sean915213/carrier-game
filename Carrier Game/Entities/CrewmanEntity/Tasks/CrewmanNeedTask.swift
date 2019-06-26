//
//  CrewmanNeedTask.swift
//  Carrier Game
//
//  Created by Sean G Young on 4/7/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit

class CrewmanNeedTask: CrewmanTask {
    
    private enum State {
        case none
        case moving
        case fulfilling
    }

    // MARK: - Initialization
    
    init(crewman: CrewmanEntity, need: CrewmanNeed) {
        self.need = need
        super.init(crewman: crewman)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let need: CrewmanNeed
    
    var satisfyingModuleInfo: (module: ModuleInstance, need: ModuleNeedBlueprint)? {
        guard let need = crewman.currentModule.blueprint.fulfilledNeeds.first(where: { $0.action == need.action }) else { return nil }
        return (module: crewman.currentModule, need: need)
    }
    
    private var state: State = .none
    
    override func beginTaskControl() {
        super.beginTaskControl()
    }
    
    override func endTaskControl() {
        super.endTaskControl()
    }
    
    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)
        // FIRST: Change need value based on current module
        updateNeedValue(deltaTime: deltaTime)
        // SECOND: Pursue based on whether this need has priority
        guard taskControl else { return }
        // Unless state is none, we're performing some kind of action so nothing to do
        guard case .none = state else { return }
        // If we're in a fulfilling module then perform fulfilling action
        if let (module, _) = satisfyingModuleInfo {
            performNeed(in: module)
        } else {
            // Otherwise begin moving to need
            moveToNeed()
        }
    }

    override func calculatePriority() -> TaskPriority {
        // TODO: NEED BETTER LOGIC
        if crewman.isOnShift {
            return .none
        } else {
            // TODO: TOTAL DEBUGGING HERE
            return .high
        }
    }
    
    private func updateNeedValue(deltaTime: TimeInterval) {
        // Find a fulfilled need on this module matching crewman's lead
        if let (_, fulfillingNeed) = satisfyingModuleInfo {
            // Increment need value
            need.addValue(fulfillingNeed.increaseFactor * deltaTime)
        } else {
            // Decrement need by decay time
            need.subtractValue(need.decayFactor * deltaTime)
        }
    }
    
    private func moveToNeed() {
        // Find modules that would satisfy this need
        let satisfyingModules = crewman.ship.allModules.filter { module -> Bool in
            return module.blueprint.fulfilledNeeds.contains(where: { $0.action == need.action })
        }
        // Find the closest entrance we could move to in one of these modules
        guard let entranceInfo = findClosestEntrance(in: satisfyingModules) else {
            // TODO: Logging this results in spam if crewman is stuck in an orphaned module. But should note this somehow?
            return
        }
        // Set to moving
        state = .moving
        // Move to module and set status when completed
        setMovementPath(entranceInfo.path) { result in
            self.state = .none
        }
    }
    
    private func performNeed(in module: ModuleInstance) {
        // Find a random coordinate within this module
        let rect = module.placement.absoluteRect
        let xCoord = rect.xRange.randomElement()!
        let yCoord = rect.yRange.randomElement()!
        // Check for open node here
        guard let node = crewman.ship.blueprint.graph.node(atPoint: GridPoint3(xCoord, yCoord, GridPoint(rawValue: Int(module.deck.blueprint.position)))) else {
            return
        }
        // Find path
        let path = getCrewmanGraphNode().findPath(to: node) as! [GKGridGraphNode3D]
        // If empty then no path (which probably should not happen?)
        guard !path.isEmpty else {
            logger.logError("Found empty meander path. Why would an orphaned graph node exist? Destination: \(node)")
            return
        }
        // Set movement
        state = .moving
        setMovementPath(path) { result in
            self.state = .none
        }
    }
}

extension CrewmanNeedTask: CustomDebugStringConvertible {
    var debugDescription: String {
        return "Need Action: \(need.action)"
    }
}
