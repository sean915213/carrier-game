//
//  NSPersistentContainerExtension.swift
//  Carrier Game
//
//  Created by Sean G Young on 10/26/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData

private let modelContainer = NSPersistentContainer(name: "Model")

extension NSPersistentContainer {
    static var model: NSPersistentContainer { return modelContainer }
    
    // TODO: MOVE TO UTILITY
    
    enum Failure: Error { case storeMissingURL }
    
    func deleteAllStores(completed: @escaping (Error?) -> Void) {
        // Must first load stores
        NSPersistentContainer.model.loadPersistentStores { (_, error) in
            if let e = error {
                completed(e)
                return
            }
            // Destroy loaded stores
            for store in self.persistentStoreCoordinator.persistentStores {
                // Get URL
                guard let url = store.url else {
                    completed(Failure.storeMissingURL)
                    return
                }
                // Destroy
                do {
                    try self.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: store.type, options: nil)
                } catch {
                    completed(error)
                    return
                }
            }
            // Return nil to indicate success
            completed(nil)
        }
    }
}
