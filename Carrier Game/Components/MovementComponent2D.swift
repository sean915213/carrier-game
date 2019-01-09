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
    
    override func willRemoveFromEntity() {
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
                // Assign on entity's instance
                self.crewman?.instance.position = CDPoint3(newNode.position)
                // Check whether visible now
                self.updateVisibility(at: node.position.z)
            }
            // Put into sequence so that update only happens once other actions are completed
            let sequenceAction = SKAction.sequence([moveAction, postAction])
            // Add sequence to final action array
            allActions.append(sequenceAction)
        }
        // Add a completed block since we cannot add completion while also assigning key
        allActions.append(SKAction.run {
            // Nil relevant properties
            self.path = nil
            self.remainingPath = nil
            self.callback = nil
            // Execute callback
            completed?(.completed)
        })
        // Place actions into a sequence and make node run
        let moveSequence = SKAction.sequence(allActions)
        movementNode.run(moveSequence, withKey: moveActionKey)
    }
    
    private func cancelRunningAction() {
        // If action already exists on node then remove
        guard movementNode.action(forKey: moveActionKey) != nil else { return }
        // Remove to cancel
        movementNode.removeAction(forKey: moveActionKey)
        // Execute callback since removing will not execute the action that does so
        self.callback?(.interrupted)
    }
    
    private func updateVisibility(at vertical: GridPoint) {
        if movementNode.isHidden && visibleVertical == vertical {
            movementNode.isHidden = false
        } else if !movementNode.isHidden && visibleVertical != vertical {
            self.movementNode.isHidden = true
        }
    }
}
