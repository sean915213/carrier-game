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
    
    private var tasks = [CrewmanTask]()
    private var activeTask: CrewmanTask?
    
    private lazy var logger = Logger(source: "Crewman (\(instance.name))")
    
    var rootNode: SKNode {
        return component(ofType: GKSKNodeComponent.self)!.node
    }
    
    var gridPosition: GridPoint3 {
        return GridPoint3(instance.position)
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
        // - Needs
        for need in instance.needs {
            print("&& CREWMAN [\(instance.name)] ADDING NEED: \(need.action)")
            let task = CrewmanNeedTask(crewman: self, need: need)
            tasks.append(task)
        }
        // - Job
        guard let job = instance.job else {
            // TODO: Implement logic for finding job
            fatalError("Crewman without pre-assigned job not implemented.")
        }
        let jobTask = CrewmanJobTask(crewman: self, job: job)
        tasks.append(jobTask)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        // Update all tasks
        updateTasks(deltaTime: seconds)
        // Update task
        updateTask()
    }
    
    private func updateTasks(deltaTime seconds: TimeInterval) {
        tasks.forEach { $0.update(deltaTime: seconds) }
    }
    
    // MARK: State Logic
    
    private func updateTask() {
        // Order tasks by priority and get highest
        guard let priorityTask = tasks.sorted(by: { $0.priority > $1.priority }).first else {
            logger.logError("Crewman has no tasks to update.")
            return
        }
        // If priority task isn't active task then begin a new task
        guard priorityTask !== activeTask else { return }
        activeTask?.endTaskControl()
        priorityTask.beginTaskControl()
        activeTask = priorityTask
        logger.logDebug("New priority task: \(priorityTask)")
    }
    
    // MARK: StatsProvider Implementation
    
    func provideStats() -> (name: String, stats: [Stat]) {
        let stats = instance.needs.map { return Stat(name: String(describing: $0.action), value: $0.value) }
        return (instance.name, stats)
    }
}
