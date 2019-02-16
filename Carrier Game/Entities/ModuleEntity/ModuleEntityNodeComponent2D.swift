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
        didSet { updateEditingOverlay() }
    }
    
    private var modulePlacement: ModulePlacement? {
        return (entity as? ModuleEntity)?.placement
    }
    
    private var editingOverlayNode: SKNode?
    
    private var positionObserver: NSKeyValueObservation?
    
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
        configureMainNode()
        configureTextureNodes()
        configureObserver()
    }
    
    override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        node = SKNode()
    }
    
    private func configureMainNode() {
        guard let placement = modulePlacement else {
            fatalError("\(#function) called without an assigned placement.")
        }
        // Configure main node
        node = SKNode()
        node.name = "Module: \(String(describing: self))"
        node.position = CGPoint(placement.origin)
        node.zRotation = CGFloat(placement.rotation.radians)
    }

    private func configureTextureNodes() {
        guard let placement = modulePlacement else {
            fatalError("\(#function) called without an assigned placement.")
        }
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
    
    private func updateEditingOverlay() {
        
    }
    
    private func updatePosition(on placement: ModulePlacement) {
        // Update node's position
        node.position = CGPoint(placement.origin)
        // Update any editing overlay
        updateEditingOverlay()
    }
    
    private func configureObserver() {
        positionObserver = (entity as! ModuleEntity).placement.observe(\ModulePlacement.origin, changeHandler: { placement, _ in
            self.updatePosition(on: placement)
        })
    }
}
