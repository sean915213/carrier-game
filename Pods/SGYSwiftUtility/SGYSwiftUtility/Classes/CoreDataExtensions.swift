//
//  NSManagedObjectContextExtension.swift
//  SGYSwiftUtility
//
//  Created by Sean G Young on 2/13/16.
//
//

import Foundation
import CoreData

public protocol NamedManagedObject where Self: NSManagedObject {
    static var entityName: String { get }
}

extension NSManagedObject: NamedManagedObject {
    public static var entityName: String { return String(describing: self) }
}

extension NamedManagedObject {
    // NOTE: fetchRequest() has an ambigious use issue so need to rename to use more easily. Also, cannot just add this to NSManagedObject because the type specific fetchRequest() class method is *generated*, and not part of the NSManagedObject class definition
    public static func makeFetchRequest() -> NSFetchRequest<Self> {
        return NSFetchRequest<Self>(entityName: Self.entityName)
    }
}

extension NSEntityDescription {
    public class func insertNewObject<T>(forEntityClass entityClass: T.Type, into context: NSManagedObjectContext) -> T where T: NamedManagedObject {
        return insertNewObject(forEntityName: entityClass.entityName, into: context) as! T
    }
}

extension NSManagedObjectContext {
    
    public func existingObject<T: NSManagedObject>(with objectID: NSManagedObjectID) throws -> T {
        // Force cast since object not found will throw and if an object is found of the wrong type the caller messed up.
        return try existingObject(with: objectID) as! T
    }
    
    public func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) throws -> T? {
        // We only expect one entry so limit request
        request.fetchLimit = 1
        return try fetch(request).first
    }
}
