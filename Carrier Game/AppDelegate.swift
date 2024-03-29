//
//  AppDelegate.swift
//  Carrier Game
//
//  Created by Sean G Young on 10/17/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit
import CoreData
import SGYSwiftUtility

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = {
        let win = UIWindow(frame: UIScreen.main.bounds)
        win.backgroundColor = UIColor.white
        return win
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        CDPoint2.registerTransformers()
        CDPoint3.registerTransformers()
        ModuleEntrance.registerTransformers()
        
        // Initial logic block
        let setupBlock = {
            // Load data models
            NSPersistentContainer.model.loadPersistentStores { (_, error) in
                if let e = error { fatalError("Failed to load CoreData model with error: \(e)") }
                DataSeeder.seedIfRequired()
                
                // TODO: FETCHING TEST SHIP BLUEPRINT
                // - Instance
                let instanceFetch = ShipInstance.makeFetchRequest()
                instanceFetch.predicate = NSPredicate(format: "name = %@", "Test Ship 2")
                let instance = try! NSPersistentContainer.model.viewContext.fetch(instanceFetch).first!
                
                // Display controller
//                self.window!.rootViewController = DeckEditingViewController(ship: instance.blueprint)
                self.window!.rootViewController = DeckSimulationViewController(ship: instance)
//                self.window!.rootViewController = ShipSceneController(ship: instance)
                self.window!.makeKeyAndVisible()
            }
        }
        
        // - BEGIN LOGIC
        
        // REMOVE CURRENT STORES (DEBUGGING)
        // TODO: Throwing migration errors?
//        DataSeeder.removeAllData { (error) in
//            if let error = error {
//                print("&& ERROR REMOVING DATA: \(error)")
//            }
//            // Perform normal setup
//            setupBlock()
//        }
        
        // KEEP CURRENT STORES
        setupBlock()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

