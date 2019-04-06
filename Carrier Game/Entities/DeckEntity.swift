//
//  DeckEntity.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/27/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit
import GameplayKit
import SGYSwiftUtility

class DeckEntity: GKEntity {

    // MARK: - Initialization
    
    init(blueprint: DeckBlueprint) {
        self.blueprint = blueprint
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let blueprint: DeckBlueprint
    
    private(set) var moduleEntities = [ModuleEntity]()
    
    private(set) lazy var node: SKNode = {
        let textureNode = SKNode()
        textureNode.name = "Deck [\(blueprint.position)]"
        return textureNode
    }()
    
    // MARK: - Methods
    
    private func setup() {
        for placement in blueprint.modulePlacements {
            addModuleEntity(for: placement)
        }
    }
    
    @discardableResult
    func addModuleEntity(for placement: ModulePlacement) -> ModuleEntity {
        // Create entity and add to list
        let entity = ModuleEntity(placement: placement)
        moduleEntities.append(entity)
        // Add texture node to our root node
        node.addChild(entity.mainNodeComponent.node)
        return entity
    }
    
    func removeModuleEntity(_ entity: ModuleEntity) {
        // Get index
        guard let index = moduleEntities.firstIndex(of: entity) else {
            assertionFailure("Asked to remove module entity that does not exist in collection.")
            return
        }
        // Remove entity and node
        moduleEntities.remove(at: index)
        entity.mainNodeComponent.node.removeFromParent()
    }
    
    func flashInvalidPoints<T>(_ points: T) where T: Sequence, T.Element == GridPoint2 {
        // Add flashing node components
        for point in points {
            let node = SKSpriteNode(color: .red, size: CGSize(width: 1, height: 1))
            node.alpha = 0
            node.position = CGPoint(point)
            self.node.addChild(node)
            // Add flashing action in repeated sequence
            let fadeIn = SKAction.fadeIn(withDuration: 0.6)
            let fadeOut = fadeIn.reversed().withDuration(0.6)
            let flashRepeat = SKAction.repeat(SKAction.sequence([fadeIn, fadeOut]), count: 3)
            // Add final action to remove from parent and pack into final sequence
            let actionSequence = SKAction.sequence([flashRepeat, SKAction.removeFromParent()])
            node.run(actionSequence)
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        // Update module entities
        moduleEntities.forEach { $0.update(deltaTime: seconds) }
    }
}

// TODO: MOVE TO UTILITY?
extension SKAction {
    
    func withDuration(_ duration: TimeInterval) -> SKAction {
        let action = copy() as! SKAction
        action.duration = duration
        return action
    }
}
