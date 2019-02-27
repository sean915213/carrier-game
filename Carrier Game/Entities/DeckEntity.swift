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

// TODO: ANY REASON FOR THERE TO BE A DECK ENTITY- EXCEPT TO ORGANIZE SCENEKIT RELATED FUNCTIONS? ENTITY SHOULD PROBABLY ONLY BE REQUIRED IF REACTIGN TO TIME UPDATES
class DeckEntity: GKEntity {

    // MARK: - Initialization
    
    init(instance: DeckInstance) {
        self.instance = instance
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let instance: DeckInstance
    
    var blueprint: DeckBlueprint {
        return instance.blueprint
    }
    
    lazy var moduleEntities: [ModuleEntity] = {
        let entities = blueprint.modulePlacements.map { ModuleEntity(placement: $0) }
        for entity in entities {
            print("&& DECK [\(blueprint.position)] MODULE ENTITY: \(entity.blueprint.identifier). ORIGIN: \(entity.placement.origin)")
            
        }
        return entities
    }()
    
    // TODO: CHANGED THIS TO ONLY USE METHOD AND NOT TRACK OURSELF. DON'T REMEMBER WHY. MAYBE ANTICIPATIG THIS MANAGING EITHER A 3D or 2D NODE?
    private(set) lazy var node: SKNode = {
        let textureNode = SKNode()
        textureNode.name = "Deck [\(blueprint.position)]"
        for module in moduleEntities {
            textureNode.addChild(module.mainNodeComponent.node)
        }
        return textureNode
    }()
    
    // MARK: - Methods
    
//    func makeNode() -> SKNode {
//        let textureNode = SKNode()
//        textureNode.name = "Deck [\(blueprint.position)]"
//        for module in moduleEntities {
//            textureNode.addChild(module.mainNodeComponent.node)
//        }
//        return textureNode
//    }
    
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
}

// TODO: MOVE TO UTILITY?
extension SKAction {
    
    func withDuration(_ duration: TimeInterval) -> SKAction {
        let action = copy() as! SKAction
        action.duration = duration
        return action
    }
}
