//
//  DeckScene.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/12/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import SpriteKit
import GameplayKit

//protocol DeckSceneDelegate: SKSceneDelegate {
//
//    func deckScene(_: DeckScene, got)
//
//
//}

class DeckScene: SKScene {
    
    // MARK: - Initialization
    
    // MARK: - Properties
    
    var entities = [GKEntity]()
    lazy var reporter = StatReportingEntity()
    
    private var lastUpdate: TimeInterval = 0
    
    // MARK: - Methods

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        
        // TODO: This seems a bit hacky. Should instead just use time on ship instance and make this an animation only thing vs. an in-game time thing?
        
        // Transform to game time for entity updates
        let gameTime = currentTime * ((60 * 60) / 3.0) * 2
        
        // Assign last value when returning
        defer { lastUpdate = gameTime }
        // If lastUpdate is zero this is first update so just return
        guard lastUpdate != 0 else { return }
        // Update entities with time difference
        let dt = gameTime - lastUpdate
        for entity in entities {
            entity.update(deltaTime: dt)
        }
        // Update on stat reporter AFTER entities are updated
        reporter.update(deltaTime: dt)
    }
}
