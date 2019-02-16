//
//  ModuleEntityNodeComponent2D.swift
//  Carrier Game
//
//  Created by Sean G Young on 2/15/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit
import GameplayKit

class ModuleEntityNodeComponent2D: GKSKNodeComponent {
    
    // MARK: - Initialization
    
    // MARK: - Properties
    
    var showEditingOverlay = false {
        didSet {
            guard let placement = modulePlacement else {
                // TODO: LOG THIS
                return
            }
            toggleEditingOverlay(on: placement)
        }
    }
    
    private var modulePlacement: ModulePlacement? {
        return (entity as? ModuleEntity)?.placement
    }
    
    private lazy var editingOverlayNodes = [GridPoint2: SKSpriteNode]()
    
    private lazy var positionObservers = [NSKeyValueObservation]()
    
    private var moduleGridPoints: [GridPoint2] {
        var points = [GridPoint2]()
        guard let placement = modulePlacement else { return points }
        for x in GridPoint.zero..<GridPoint(placement.blueprint.size.x) {
            for y in GridPoint.zero..<GridPoint(placement.blueprint.size.y) {
                points.append(GridPoint2(x, y))
            }
        }
        return points
    }
    
    // MARK: - Methods
    
    override func didAddToEntity() {
        super.didAddToEntity()
        guard let placement = modulePlacement else {
            fatalError("\(#function) called without an assigned placement.")
        }
        configureMainNode(on: placement)
        configureTextureNodes(on: placement)
        configureObservers(on: placement)
    }
    
    override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        node = SKNode()
    }
    
    private func configureMainNode(on placement: ModulePlacement) {
        // Configure main node
        node = SKNode()
        node.name = "Module: \(String(describing: self))"
        // Perform initial position and rotation updates
        updatePosition(on: placement)
        updateRotation(on: placement)
    }

    private func configureTextureNodes(on placement: ModulePlacement) {
        let blueprint = placement.blueprint
        // NOTE: Texture nodes are placed according to *relative* position since they are attached to one main node that is placed at the placement's origin and rotated as needed.
        let borderPoints = Set(blueprint.wallCoords)
        for point in moduleGridPoints {
            // A node is always made
            let childNode = SKSpriteNode()
            childNode.name = "Texture"
            childNode.size = CGSize(width: 1, height: 1)
            childNode.position = CGPoint(point)
            node.addChild(childNode)
            // Check whether this is a wall
            let cdPoint = CDPoint2(point)
            guard !borderPoints.contains(cdPoint) else {
                childNode.texture = SKTexture(image: UIImage(named: "Barrel")!)
                continue
            }
            // Check whether this is an entrance
            if let entrance = blueprint.entrances.first(where: { $0.coordinate == cdPoint }) {
                if entrance.zAccess {
                    childNode.color = .yellow
                } else {
                    childNode.color = .brown
                }
                continue
            }
            // Otherwise simply open, no-entrance texture
            childNode.color = .white
        }
    }
    
    private func toggleEditingOverlay(on placement: ModulePlacement) {
        if showEditingOverlay && editingOverlayNodes.isEmpty {
            print("&& ADD EDIT NODES")
            addEditingOverlayNodes(on: placement)
        } else {
            print("&& REMOVING EDIT NODES")
            for (_, overlayNode) in editingOverlayNodes {
                overlayNode.removeFromParent()
            }
            editingOverlayNodes.removeAll(keepingCapacity: true)
        }
    }
    
    private func addEditingOverlayNodes(on placement: ModulePlacement) {
        for point in moduleGridPoints {
            let spriteNode = SKSpriteNode()
            spriteNode.size = CGSize(width: 1, height: 1)
            spriteNode.position = CGPoint(point)
            editingOverlayNodes[point] = spriteNode
            node.addChild(spriteNode)
        }
        // Perform first update to assign colors properly
        updateEditingOverlayNodes(on: placement)
    }
    
    private func updateEditingOverlayNodes(on placement: ModulePlacement) {
        // Do not perform if not editing
        guard showEditingOverlay else { return }
        // Ask deck for list of invalid points. Since we're editing it would be our points overlapping.
        let invalidPoints = placement.deck.validate(conditions: .modulePlacements)
        // Update the overlay on our points
        for (point, node) in editingOverlayNodes {
            let absPoint3 = placement.absolutePoint(fromRelative: point)
            let absPoint = GridPoint2(absPoint3.x, absPoint3.y)
            // Determine overlay color
            let overlayColor: UIColor
            if invalidPoints.contains(absPoint) {
                overlayColor = .red
            } else {
                overlayColor = .green
            }
            // Assign overlay color
            node.color = overlayColor.withAlphaComponent(0.8)
        }
    }
    
    private func updatePosition(on placement: ModulePlacement) {
        // Update node's position
        node.position = CGPoint(placement.origin)
        // Update any editing overlay
        updateEditingOverlayNodes(on: placement)
    }
    
    private func updateRotation(on placement: ModulePlacement) {
        // Update node's rotation
        node.zRotation = CGFloat(placement.rotation.radians)
        // Update any editing overlay
        updateEditingOverlayNodes(on: placement)
    }
    
    private func configureObservers(on placement: ModulePlacement) {
        positionObservers.append(placement.observe(\.origin, changeHandler: { placement, _ in
            self.updatePosition(on: placement)
        }))
        positionObservers.append(placement.observe(\.rotation, changeHandler: { placement, _ in
            self.updateRotation(on: placement)
        }))
    }
}
