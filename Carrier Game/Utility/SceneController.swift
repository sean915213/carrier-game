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

class SceneController<SceneType> where SceneType: SKScene {
    
    // MARK: - Initialization
    
    init(scene: SceneType, context: NSManagedObjectContext) {
        self.scene = scene
        self.context = context
        registerForNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Properties
    
    let scene: SceneType
    let context: NSManagedObjectContext
    var autoManagePause = true
    var autoSave = false
    
    private lazy var logger = Logger(source: type(of: self))
    
    // MARK: - Methods
    
    private func registerForNotifications() {
        // Did become active
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
            self.applicationDidBecomeActive()
        }
        // Resigning active
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { _ in
            self.applicationWillResignActive()
        }
        // Entering background
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
            self.applicationDidEnterBackground()
        }
    }
    
    private func applicationDidBecomeActive() {
        guard autoManagePause else { return }
        logger.logInfo("Application became active. Resuming scene.")
        scene.isPaused = false
    }
    
    private func applicationWillResignActive() {
        guard autoManagePause else { return }
        logger.logInfo("Application resigning active. Pausing scene.")
        scene.isPaused = true
    }
    
    private func applicationDidEnterBackground() {
        guard autoSave else { return }
        logger.logInfo("Application entering background. Saving data.")
        do {
            try context.save()
        } catch {
            logger.logError("Caught error saving model context: \(error)")
        }
    }
}
