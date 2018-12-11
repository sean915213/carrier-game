//
//  SceneController.swift
//  Carrier Game
//
//  Created by Sean G Young on 12/8/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import SpriteKit
import SGYSwiftUtility
import CoreData

class SceneController {
    
    // MARK: - Initialization
    
    init(scene: SKScene) {
        self.scene = scene
        registerForNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Properties
    
    let scene: SKScene
    
    private lazy var logger = Logger(source: type(of: self))
    
    // MARK: - Methods
    
    private func registerForNotifications() {
        // Resigning active
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { _ in
            self.logger.logInfo("Application resigning active. Pausing scene.")
            self.scene.isPaused = true
        }
        // Entering background
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
            self.logger.logInfo("Application entering background. Saving data.")
            do {
                try NSPersistentContainer.model.viewContext.save()
            } catch {
                self.logger.logError("Caught error saving model context: \(error)")
            }
        }
        // Did become active
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
            self.logger.logInfo("Application became active. Resuming scene.")
            self.scene.isPaused = false
        }
    }
}
