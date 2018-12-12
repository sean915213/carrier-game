//
//  Module.swift
//  Carrier Game
//
//  Created by Sean G Young on 10/26/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData
import GameKit
import SGYSwiftUtility

class ModuleBlueprint: NSManagedObject, IdentifiableEntity {
    
    @NSManaged var name: String
    @NSManaged var identifier: String
    @NSManaged var size: CDPoint2
    @NSManaged var mass: Measurement<UnitMass>
    
    @NSManaged var attributes: [String: Double]
    
    @NSManaged var xyOpenCoords: Set<CDPoint2>
    @NSManaged var zOpenCoords: Set<CDPoint2>
    
    @NSManaged var fulfilledNeeds: Set<ModuleNeedBlueprint>
    @NSManaged var jobs: Set<ModuleJobBlueprint>
    
    override func awakeFromInsert() {
        // Set empty attributes dict
        attributes = [:]
    }
}

typealias ModuleAttribute = String
extension ModuleAttribute {
    static let crewSupported = "crew_supported"
    static let engineThrust = "engine_thrust"
}
