//
//  CrewmanTask.swift
//  Carrier Game
//
//  Created by Sean G Young on 4/7/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit
import GameplayKit
import SGYSwiftUtility

// TODO: Continue modifying pathfinding so that we can attempt simple movement to an arbitrary GridPoint3
// 1. Expand base functions including those that calculate a path? Then composite those into existing find closest entrance function?
// OR: Could make find closest entrance generic by passing a type that adheres to a protocol that exposes its gridpoint? Otherwise would need a few helper functions when getting closest among different types (or somehow associated closest found path with the matching item).
// 2. Use new function(s) to convert move to entrance logic for jobs to move to the specific position if it exists?

typealias TaskPriority = Int
extension TaskPriority {
    static let required = 100
    static let urgent = 75
    static let high = 50
    static let low = 25
    static let none = 0
    
    static let workShift: TaskPriority = .urgent
}

class CrewmanTask {
    
    enum PathFailure: Error { case invalidDestination, noPath }
    
    // MARK: - Initialization
    
    init(crewman: CrewmanEntity) {
        self.crewman = crewman
    }

    // MARK: - Properties
    
    var priority: TaskPriority {
        return calculatePriority()
    }
    
    // TODO: DOES UNOWNED FIX WHAT WOULD BE A REF CYCLE HERE?
    unowned let crewman: CrewmanEntity
    
    private(set) lazy var logger = Logger(source: "\(type(of: self)) [\(crewman.instance.name)]")
    
    private(set) var taskControl: Bool = false
    private(set) var controlDuration: Measurement<UnitDuration>?

    // MARK: - Methods
    
    func calculatePriority() -> TaskPriority {
        return .none
    }
    
    func beginTaskControl() {
        taskControl = true
        controlDuration = Measurement(value: 0, unit: .seconds)
    }
    
    func endTaskControl() {
        taskControl = false
        controlDuration = nil
    }
    
    func update(deltaTime seconds: TimeInterval) {
        // If controlDuration is populated we have control so add to current duration
        guard let duration = controlDuration else { return }
        controlDuration = duration + Measurement(value: seconds, unit: .seconds)
    }
    
    // TODO: REVERT TO RETURNING JUST PATH UNLESS OTHER INFO IS BEING USED
    func findClosestEntrance(in modules: [ModuleInstance]) -> (module: ModuleInstance, entrance: GridPoint3, path: [GKGridGraphNode3D])? {
        // Collect shortest path info
        var shortestInfo: (module: ModuleInstance, entrance: GridPoint3, path: [GKGridGraphNode3D])?
        for module in modules {
            let entranceCoords = module.placement.absoluteEntrances.map { $0.coordinate }
            for entrance in entranceCoords {
                // Get path
                do {
                    let path = try findPath(to: entrance)
                    // If existing path is <= new count then continue
                    if let info = shortestInfo, info.path.count <= path.count { continue }
                    // Assign new info
                    shortestInfo = (module: module, entrance: entrance, path: path)
                } catch {
                    fatalError("Inability to find path not implemented. This is likely valid in some scenarios but they haven't been accounted for.")
                }
            }
        }
        return shortestInfo
    }
    
    // TODO: Implement somehow or remove
    func findShortestPath(among points: [GridPoint3]) -> (point: GridPoint3, path: [GKGridGraphNode3D])? {
        // Get origin node in ship's graph
        let originNode = getCrewmanGraphNode()
        // Determine shortest path
        var shortest: (point: GridPoint3, path: [GKGridGraphNode3D])?
        for point in points {
            // Get node
            guard let node = crewman.ship.blueprint.graph.node(atPoint: point) else {
                continue
            }
            // Get path
            let path = originNode.findPath(to: node) as! [GKGridGraphNode3D]
            // If empty then path doesn't exist
            guard !path.isEmpty else { continue }
            // If shortest exists and this path is longer continue
            if let (_, currentPath) = shortest, currentPath.count <= path.count { continue }
            // Assign new shortest
            shortest = (point, path)
        }
        return shortest
    }
    
    func findPath(to point: GridPoint3) throws -> [GKGridGraphNode3D] {
        // Get destination node
        guard let destinationNode = crewman.ship.blueprint.graph.node(atPoint: point) else {
            throw PathFailure.invalidDestination
        }
        // Find path
        let path = getCrewmanGraphNode().findPath(to: destinationNode) as! [GKGridGraphNode3D]
        guard !path.isEmpty else { throw PathFailure.noPath }
        // Return path
        return path
    }
    
    func setMovementPath(_ path: [GKGridGraphNode3D], completed: @escaping (MovementResult) -> Void) {
        guard let movementComponent = crewman.components.first(where: { $0 is MovementComponentProtocol }) as? MovementComponentProtocol else {
            assertionFailure("\(#function) called without a component conforming to MovementComponentProtocol.")
            return
        }
        // Assign movement
        movementComponent.setPath(nodes: path, completed: completed)
    }
    
    func getCrewmanGraphNode() -> GKGridGraphNode3D {
        guard let node = crewman.ship.blueprint.graph.node(atPoint: GridPoint3(crewman.instance.position)) else {
            assertionFailure("\(#function) unable to find a graph node associated with instance's position.")
            return GKGridGraphNode3D(point: GridPoint3.zero)
        }
        return node
    }
}
