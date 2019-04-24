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

// TODO: Continue fleshing out jobs/needs.
// - Expand job instance with locations where job is performed?
// - Should job customization be done via class or via model options? I.e. cook adding food?

typealias TaskPriority = Int
extension TaskPriority {
    static let required = 100
    static let urgent = 75
    static let high = 50
    static let low = 25
    static let none = 0
}

class CrewmanTask {
    
    // MARK: - Initialization
    
    init(crewman: CrewmanEntity) {
        self.crewman = crewman
    }

    // MARK: - Properties
    
    var priority: TaskPriority {
        return calculatePriorty()
    }
    
    // TODO: DOES UNOWNED FIX WHAT WOULD BE A REF CYCLE HERE?
    unowned let crewman: CrewmanEntity
    
    private(set) lazy var logger = Logger(source: "\(type(of: self))")
    
    private(set) var taskControl: Bool = false

    // MARK: - Methods
    
    func calculatePriorty() -> TaskPriority {
        return .none
    }
    
    func beginTaskControl() {
        taskControl = true
    }
    
    func endTaskControl() {
        taskControl = false
    }
    
    func update(deltaTime seconds: TimeInterval) {
        // Provided for common override
    }
    
    func findClosestEntrance(from crewman: CrewmanEntity, in modules: [ModuleInstance]) -> (module: ModuleInstance, entrance: GKGridGraphNode3D, path: [GKGridGraphNode3D])? {
        // Get origin node in ship's graph
        let originNode = getGraphNode()
        // Collect distances to entrances
        var distanceInfo = [(module: ModuleInstance, entrance: GKGridGraphNode3D, path: [GKGridGraphNode3D])]()
        for module in modules {
            let entranceCoords = module.placement.absoluteEntrances.map { $0.coordinate }
            for entrance in entranceCoords {
                // Get node
                guard let node = crewman.ship.blueprint.graph.node(atPoint: entrance) else {
                    assertionFailure("\(#function) found module entrance with no associated graph node.")
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
        // Return shortest entrance
        return distanceInfo.min(by: { $0.path.count < $1.path.count })
    }
    
    func setMovementPath(_ path: [GKGridGraphNode3D], completed: @escaping (MovementResult) -> Void) {
        guard let movementComponent = crewman.components.first(where: { $0 is MovementComponentProtocol }) as? MovementComponentProtocol else {
            assertionFailure("\(#function) called without a component conforming to MovementComponentProtocol.")
            return
        }
        // Assign movement
        movementComponent.setPath(nodes: path, completed: completed)
    }
    
    func getGraphNode() -> GKGridGraphNode3D {
        guard let node = crewman.ship.blueprint.graph.node(atPoint: GridPoint3(crewman.instance.position)) else {
            assertionFailure("\(#function) unable to find a graph node associated with instance's position.")
            return GKGridGraphNode3D(point: GridPoint3.zero)
        }
        return node
    }
}
