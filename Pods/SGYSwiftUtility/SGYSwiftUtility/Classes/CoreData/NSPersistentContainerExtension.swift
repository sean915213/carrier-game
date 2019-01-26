//
//  NSPersistentContainerExtension.swift
//  SGYSwiftUtility
//
//  Created by Sean G Young on 1/26/19.
//

import Foundation
import CoreData

@available(iOS 10.0, *)
extension NSPersistentContainer {
    
    public enum Failure: Error { case storeMissingURL }
    
    /// Destroys all stores related to this persistent container.
    ///
    /// - Parameter completed: A closure called when the operation completes with an optional `Failure` if one was encountered.
    public func destroyAllStores(completed: @escaping (Error?) -> Void) {
        // Must first load stores
        loadPersistentStores { (_, error) in
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
