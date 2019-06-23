//
//  CrewmanJobTask.swift
//  Carrier Game
//
//  Created by Sean G Young on 4/7/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit

class CrewmanJobTask: CrewmanTask {
    
    private enum State {
        case none
        case moving
        case working
    }
    
    // MARK: - Initialization
    
    init(crewman: CrewmanEntity, job: ModuleJobInstance) {
        self.job = job
        super.init(crewman: crewman)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let job: ModuleJobInstance
    
    private var state: State = .none
    
    override func beginTaskControl() {
        super.beginTaskControl()
    }
    
    override func endTaskControl() {
        super.endTaskControl()
        // Reset state
        state = .none
    }
    
    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)
        // If task doesn't have control then no work to be done for job
        guard taskControl else { return }
        // Unless state is none, we're performing some kind of action so nothing to do
        guard case .none = state else { return }
        // If we're in the job's module then update work
        if crewman.currentModule == job.module {
            updateWork(deltaTime: deltaTime)
        } else {
            // Otherwise move to module
            moveToJob()
        }
    }
    
    override func calculatePriority() -> TaskPriority {
        // TODO: NEED BETTER LOGIC
        if crewman.isOnShift {
            return .workShift
        } else {
            return .none
        }
    }
    
    private func updateWork(deltaTime: TimeInterval) {
        // TODO: ANY LOGIC FOR GENERIC JOB? MEANDERING? ETC?
    }
    
    private func moveToJob() {
        // Find the closest entrance we could move to for job
        guard let entranceInfo = findClosestEntrance(from: crewman, in: [job.module]) else {
            // TODO: Logging this results in spam if crewman is stuck in an orphaned module. But should note this somehow?
            return
        }
        // Set to moving
        state = .moving
        // Move to module and set status when completed
        setMovementPath(entranceInfo.path) { result in
            switch result {
            case .interrupted:
                // Reset to none if interrupted
                self.state = .none
            case .completed:
                // Set as working if moved
                self.state = .working
            }
        }
    }
    
//    private func performNeed(in module: ModuleInstance, for crewman: CrewmanEntity) {
//        // Find a random coordinate within this module
//        let rect = module.placement.absoluteRect
//        let xCoord = rect.xRange.randomElement()!
//        let yCoord = rect.yRange.randomElement()!
//        // Check for open node here
//        guard let node = crewman.ship.blueprint.graph.node(atPoint: GridPoint3(xCoord, yCoord, GridPoint(rawValue: Int(module.deck.blueprint.position)))) else {
//            return
//        }
//        // Find path
//        let path = getGraphNode(for: crewman).findPath(to: node) as! [GKGridGraphNode3D]
//        // If empty then no path (which probably should not happen?)
//        guard !path.isEmpty else {
//            logger.logError("Found empty meander path. Why would an orphaned graph node exist? Destination: \(node)")
//            return
//        }
//        // Set movement
//        setMovementPath(path, for: crewman) { result in
//            // Instead of checking for interrupted, etc just set state back to none and if we still have task control we'll continue next update
//            self.state = .none
//        }
//    }
}

extension CrewmanJobTask: CustomDebugStringConvertible {
    var debugDescription: String {
        return "Job Instance { action: \(job.blueprint.action), module: \(job.blueprint.module.identifier) }"
    }
}
