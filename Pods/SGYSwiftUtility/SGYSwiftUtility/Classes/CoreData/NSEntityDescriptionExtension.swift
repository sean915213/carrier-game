//
//  NSEntityDescriptionExtension.swift
//  SGYSwiftUtility
//
//  Created by Sean G Young on 11/3/18.
//

import Foundation
import CoreData

extension NSEntityDescription {
    
    public class func insertNewObject<T>(forEntityClass entityClass: T.Type, into context: NSManagedObjectContext) -> T where T: NamedManagedObject {
        return insertNewObject(forEntityName: entityClass.entityName, into: context) as! T
    }
}
