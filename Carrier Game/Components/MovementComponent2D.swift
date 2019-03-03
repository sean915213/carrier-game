//
//  MovementComponent2D.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/12/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

private let moveActionKey = "com.sdot.movementAction"

class MovementComponent2D: GKComponent, MovementComponentProtocol {
    
    var visibleVertical = GridPoint(0) {
        didSet {
            guard let crewman = crewman else { return }
            updateVisibility(at: GridPoint(crewman.instance.position.z))
        }
    }
    
    // TODO: Make all these into a single struct?
    private(set) var path: [GKGridGraphNode3D]?
    private(set) var remainingPath: [GKGridGraphNode3D]?
    private(set) var callback: ((MovementResult) -> Void)?
    
    private var movementNode: SKNode {
        return entity!.component(ofType: GKSKNodeComponent.self)!.node
    }
    
    // TODO: If more entities need movement then can generalize this w/ protocol. Will require exposing coords on a protocol that can be updated and updates the associated managed object
    private var crewman: CrewmanEntity? {
        return entity as? CrewmanEntity
    }
    
    override func didAddToEntity() {
        super.didAddToEntity()
    }
    
    override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        cancelRunningAction()
    }
    
    func setPath(nodes: [GKGridGraphNode3D], completed: ((MovementResult) -> Void)?) {
        cancelRunningAction()
        // Assign new values
        path = nodes
        remainingPath = Array(nodes[1...])
        callback = completed
        // Make actions to move along this path
        var allActions = [SKAction]()
        for node in nodes[1...] {
            // Always perform move action. If changing verticals then won't move anywhere but still serves to add a timing element
            let moveAction = SKAction.move(to: CGPoint(x: CGFloat(node.position.x), y: CGFloat(node.position.y)), duration: 1)
            // Create block action to remove from remaining path and assign on entity's instance
            let postAction = SKAction.run {
                // Remove the position we just moved to
                let newNode = self.remainingPath!.removeFirst()
                // Assign position on instance and update visibility
                self.assignPosition(at: newNode.position)
            }
            // Put into sequence so that update only happens once other actions are completed
            let sequenceAction = SKAction.sequence([moveAction, postAction])
            // Add sequence to final action array
            allActions.append(sequenceAction)
        }
        // Add a completed block since we cannot add completion while also assigning key
        allActions.append(SKAction.run {
            self.completeAction(with: .completed)
        })
        // Place actions into a sequence and make node run
        let moveSequence = SKAction.sequence(allActions)
        movementNode.run(moveSequence, withKey: moveActionKey)
    }
    
    func setPosition(_ position: GridPoint3) {
        // Cancel any running actions
        cancelRunningAction()
        // Set position on node
        movementNode.position = CGPoint(x: position.x, y: position.y)
        // Assign otherwise
        assignPosition(at: position)
    }
    
    private func assignPosition(at point: GridPoint3) {
        // Assign on entity's instance
        self.crewman?.instance.position = CDPoint3(point)
        // Check whether visible now
        self.updateVisibility(at: point.z)
    }
    
    private func cancelRunningAction() {
        // If action already exists on node then remove
        guard movementNode.action(forKey: moveActionKey) != nil else { return }
        // Remove to cancel
        movementNode.removeAction(forKey: moveActionKey)
        // Execute completion
        completeAction(with: .interrupted)
    }
    
    private func completeAction(with result: MovementResult) {
        // Execute callback
        callback?(result)
        // Nil relevant properties
        path = nil
        remainingPath = nil
        callback = nil
    }
    
    private func updateVisibility(at vertical: GridPoint) {
        if movementNode.isHidden && visibleVertical == vertical {
            movementNode.isHidden = false
        } else if !movementNode.isHidden && visibleVertical != vertical {
            self.movementNode.isHidden = true
        }
    }
}
