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
    
    func findClosestEntrance(in modules: [ModuleInstance]) -> (point: GridPoint3, path: [GKGridGraphNode3D])? {
        // Collect entrance coords from all modules
        let entranceCoords = modules.flatMap({ $0.placement.absoluteEntrances.map { $0.coordinate } })
        // Return shortest path
        return findShortestPath(among: entranceCoords)
    }
    
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
