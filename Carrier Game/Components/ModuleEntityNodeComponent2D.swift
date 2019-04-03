//
//  ModuleEntityNodeComponent2D.swift
//  Carrier Game
//
//  Created by Sean G Young on 4/2/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit
import GameplayKit

class ModuleEntityNodeComponent2D: GKSKNodeComponent {
    
    // MARK: - Initialization
    
    init(placement: ModulePlacement) {
        modulePlacement = placement
        super.init(node: SKNode())
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let modulePlacement: ModulePlacement
    
    var showEditingOverlay = false {
        didSet { toggleEditingOverlay() }
    }
    
    private lazy var editingOverlayNodes = [GridPoint2: SKSpriteNode]()
    
    private lazy var observers = [NSKeyValueObservation]()
    
    private var moduleGridPoints: [GridPoint2] {
        var points = [GridPoint2]()
        for x in GridPoint.zero..<GridPoint(modulePlacement.blueprint.size.x) {
            for y in GridPoint.zero..<GridPoint(modulePlacement.blueprint.size.y) {
                points.append(GridPoint2(x, y))
            }
        }
        return points
    }
    
    // MARK: - Methods
    
    private func setup() {
        configureMainNode()
        configureTextureNodes()
        configureObservers()
    }
    
    private func configureMainNode() {
        // Configure main node
        node.name = SKNode.Name.module.rawValue
        // Perform initial position and rotation updates
        updatePosition()
        updateRotation()
    }
    
    private func configureTextureNodes() {
        let blueprint = modulePlacement.blueprint
        // NOTE: Texture nodes are placed according to *relative* position since they are attached to one main node that is placed at the placement's origin and rotated as needed.
        let borderPoints = Set(blueprint.wallCoords)
        for point in moduleGridPoints {
            // A node is always made
            let childNode = SKSpriteNode()
            childNode.name = SKNode.Name.texture.rawValue
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
    
    private func toggleEditingOverlay() {
        if showEditingOverlay && editingOverlayNodes.isEmpty {
            addEditingOverlayNodes()
        } else {
            for (_, overlayNode) in editingOverlayNodes {
                overlayNode.removeFromParent()
            }
            editingOverlayNodes.removeAll(keepingCapacity: true)
        }
    }
    
    private func addEditingOverlayNodes() {
        for point in moduleGridPoints {
            let spriteNode = SKSpriteNode()
            spriteNode.size = CGSize(width: 1, height: 1)
            spriteNode.position = CGPoint(point)
            editingOverlayNodes[point] = spriteNode
            node.addChild(spriteNode)
        }
        // Perform first update to assign colors properly
        updateEditingOverlayNodes()
    }
    
    private func updateEditingOverlayNodes() {
        // Do not perform if not editing
        guard showEditingOverlay else { return }
        // Ask deck for list of invalid points. Since we're editing it would be our points overlapping.
        let overlappingPoints = modulePlacement.deck.findOverlappingPoints()
        // Update the overlay on our points
        for (point, node) in editingOverlayNodes {
            let absPoint3 = modulePlacement.absolutePoint(fromRelative: point)
            let absPoint = GridPoint2(absPoint3.x, absPoint3.y)
            // Determine overlay color
            let overlayColor: UIColor
            if overlappingPoints.contains(absPoint) {
                overlayColor = .red
            } else {
                overlayColor = .green
            }
            // Assign overlay color
            node.color = overlayColor.withAlphaComponent(0.8)
        }
    }
    
    private func updatePosition() {
        // Update node's position
        node.position = CGPoint(modulePlacement.origin)
        // Update any editing overlay
        updateEditingOverlayNodes()
    }
    
    private func updateRotation() {
        // Update node's rotation
        node.zRotation = CGFloat(modulePlacement.rotation.radians)
        // Update any editing overlay
        updateEditingOverlayNodes()
    }
    
    private func configureObservers() {
        observers.append(modulePlacement.observe(\.origin, changeHandler: { [unowned self] placement, _ in
            guard placement.faultingState == 0 else { return }
            self.updatePosition()
        }))
        observers.append(modulePlacement.observe(\.rotation, changeHandler: { [unowned self] placement, _ in
            guard placement.faultingState == 0 else { return }
            self.updateRotation()
        }))
    }
}
