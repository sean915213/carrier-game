//
//  IdentifiableObject.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/3/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData
import SGYSwiftUtility

protocol IdentifiableEntity: NamedManagedObject {
    var identifier: String { get }
}

extension IdentifiableEntity {
    
    static func entityWithIdentifier(_ identifier: String, using context: NSManagedObjectContext) throws -> Self? {
        let fetch = Self.makeFetchRequest()
        fetch.predicate = NSPredicate(format: "identifier = %@", identifier)
        return try context.fetch(fetch)
    }
}
