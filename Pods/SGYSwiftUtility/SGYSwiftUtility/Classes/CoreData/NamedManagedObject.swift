//
//  NamedManagedObject.swift
//  Pods-SGYSwiftUtility_Tests
//
//  Created by Sean G Young on 11/3/18.
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
