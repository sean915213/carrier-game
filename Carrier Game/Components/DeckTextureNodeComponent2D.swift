//
//  DeckTextureNodeComponent2D.swift
//  Carrier Game
//
//  Created by Sean G Young on 4/2/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit
import GameplayKit

class DeckTextureNodeComponent2D: GKSKNodeComponent {
    
    // MARK: - Initialization
    
    init(blueprint: DeckBlueprint) {
        deck = blueprint
        super.init(node: SKNode())
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let deck: DeckBlueprint
    
    // MARK: - Methods
    
    private func setup() {
        // Add node components
        for placement in deck.modulePlacements {
            let component = ModuleEntityNodeComponent2D(placement: placement)
            
        }
    }
}
