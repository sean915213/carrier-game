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
    
    @NSManaged var automaticWalls: Bool
    @NSManaged var entrances: Set<ModuleEntrance>
    
    @NSManaged var fulfilledNeeds: Set<ModuleNeedBlueprint>
    @NSManaged var jobs: Set<ModuleJobBlueprint>
    
    override func awakeFromInsert() {
        // Set defaults
        attributes = [:]
        entrances = Set<ModuleEntrance>()
    }
}

extension ModuleBlueprint {
    
    var wallCoords: [CDPoint2] {
        var coords = [CDPoint2]()
        // If not automatic walls then none
        guard automaticWalls else { return coords }
        // Map entrances to a set of coords
        let entranceCoords = Set(entrances.map({ $0.coordinate }))
        // Return border coords that are not an entrance
        let xCoords = 0..<Int(size.x)
        let yCoords = 0..<Int(size.y)
        for x in xCoords {
            for y in yCoords {
                // Check whether border
                guard x == xCoords.first || x == xCoords.last ||
                    y == yCoords.first || y == yCoords.last else { continue }
                // Check whether entrance
                let point = CDPoint2(x: CGFloat(x), y: CGFloat(y))
                guard !entranceCoords.contains(point) else { continue }
                // Should be wall
                coords.append(point)
            }
        }
        return coords
    }
}

typealias ModuleAttribute = String
extension ModuleAttribute {
    static let crewSupported = "crew_supported"
    static let engineThrust = "engine_thrust"
}
