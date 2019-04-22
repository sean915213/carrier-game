//
//  CrewmanTaskComponent.swift
//  Carrier Game
//
//  Created by Sean G Young on 4/7/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit
import GameplayKit
import SGYSwiftUtility

// TODO: NEXT- Cannot have more than one component of the same class assigned to an entity. So,
// AGAIN- Just do our own custom class and collection that a CrewmanEntity updates time on? Doesn't even have to update time really. Can customize.
// OR- Have each single component handle ALL of the needs? But then how do we determine which is active? Up to the component since needs have full reign outside of a work shift?

typealias TaskPriority = Int
extension TaskPriority {
    static let required = 100
    static let urgent = 75
    static let high = 50
    static let low = 25
    static let none = 0
}

class CrewmanTaskComponent: GKComponent {

    // MARK: - Properties
    
    var priority: TaskPriority {
        return calculatePriorty()
    }
    
    var crewman: CrewmanEntity? {
        return entity as? CrewmanEntity
    }
    
    private(set) lazy var logger = Logger(source: type(of: self))
    
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
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        guard let crewman = crewman else {
            assertionFailure("\(#function) called without assigned Crewman.")
            return
        }
        update(deltaTime: seconds, on: crewman)
    }
    
    func update(deltaTime: TimeInterval, on crewman: CrewmanEntity) {
        assertionFailure("\(#function) is abstract and should be overriden.")
    }
    
    func findClosestEntrance(from crewman: CrewmanEntity, in modules: [ModuleInstance]) -> (module: ModuleInstance, entrance: GKGridGraphNode3D, path: [GKGridGraphNode3D])? {
        // Get origin node in ship's graph
        let originNode = getGraphNode(for: crewman)
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
    
    func setMovementPath(_ path: [GKGridGraphNode3D], for crewman: CrewmanEntity, completed: @escaping (MovementResult) -> Void) {
        guard let movementComponent = crewman.components.first(where: { $0 is MovementComponentProtocol }) as? MovementComponentProtocol else {
            assertionFailure("\(#function) called without a component conforming to MovementComponentProtocol.")
            return
        }
        // Assign movement
        movementComponent.setPath(nodes: path, completed: completed)
    }
    
    func getGraphNode(for crewman: CrewmanEntity) -> GKGridGraphNode3D {
        guard let node = crewman.ship.blueprint.graph.node(atPoint: GridPoint3(crewman.instance.position)) else {
            assertionFailure("\(#function) unable to find a graph node associated with instance's position.")
            return GKGridGraphNode3D(point: GridPoint3.zero)
        }
        return node
    }
}
