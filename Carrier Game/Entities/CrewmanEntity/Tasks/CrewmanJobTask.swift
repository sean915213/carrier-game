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
    
    override func calculatePriority() -> TaskPriority {
        // TODO: NEED BETTER LOGIC
        if crewman.isOnShift {
            return .workShift
        } else {
            return .none
        }
    }
    
    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)
        // If task doesn't have control then no work to be done for job
        guard taskControl else { return }
        // Unless state is none, we're performing some kind of action so nothing to do
        guard case .none = state else { return }
        // Check whether we need to reposition to perform job
        if shouldRepositionForJob() {
            moveToJob()
        } else {
            // Perform work
            updateWork(deltaTime: deltaTime)
        }
    }
    
    private func shouldRepositionForJob() -> Bool {
        // Check whether job has a specific position
        if let jobPosition = job.blueprint.position {
            // Check whether we're in position
            if crewman.gridPosition != job.module.placement.absolutePoint(fromRelative: GridPoint2(jobPosition)) {
                return true
            }
        } else {
            // No specific position. Check whether we're in the job's module.
            if crewman.currentModule != job.module { return true }
        }
        // Reposition not required
        return false
    }
    
    private func updateWork(deltaTime: TimeInterval) {
        // TODO: ANY LOGIC FOR GENERIC JOB? MEANDERING? ETC?
    }
    
    private func moveToJob() {
        // Find the point we should move to
        let path: [GKGridGraphNode3D]
        if let jobPosition = job.blueprint.position {
            let relativePosition = job.module.placement.absolutePoint(fromRelative: GridPoint2(jobPosition))
            // Get path
            guard let (_, positionPath) = findShortestPath(among: [relativePosition]) else {
                // TODO: HANDLE
                fatalError("Need to handle inability to move to assigned job position.")
            }
            path = positionPath
        } else {
            // Job has no specific position in module so try to move to an entrance
            guard let entranceInfo = findClosestEntrance(in: [job.module]) else {
                // TODO: HANDLE
                fatalError("Need to handle inability to move to assigned job module's entrance.")
            }
            path = entranceInfo.path
        }
        // Set status to moving
        state = .moving
        // Move to position and update status when complete
        setMovementPath(path) { result in
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
}

extension CrewmanJobTask: CustomDebugStringConvertible {
    var debugDescription: String {
        return "Job Instance { action: \(job.blueprint.action), module: \(job.blueprint.module.identifier) }"
    }
}
