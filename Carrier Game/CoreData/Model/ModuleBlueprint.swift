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
    
    // TODO: DEPRECATED.
    @NSManaged var xyOpenCoords: Set<CDPoint2>
    @NSManaged var zOpenCoords: Set<CDPoint2>
    
    // TODO: NEW
    @NSManaged var entrances: Set<ModuleEntrance>
    @NSManaged var automaticWalls: Bool
    
    @NSManaged var fulfilledNeeds: Set<ModuleNeedBlueprint>
    @NSManaged var jobs: Set<ModuleJobBlueprint>
    
    override func awakeFromInsert() {
        // Set defaults
        attributes = [:]
    }
}

extension ModuleBlueprint {
    
    // TODO: BETTER TYPE HERE? CDPOINT USES FLOAT SO DECIDED ON VECTOR_INT2
    // TODO: STILL USED? COULD MAKE MORE USEFUL?
    var wallCoords: [vector_int2] {
        let xCoords = 0..<Int(size.x)
        let yCoords = 0..<Int(size.y)
        var coords = [vector_int2]()
        for x in xCoords {
            for y in yCoords {
                guard x == xCoords.first || x == xCoords.last ||
                    y == yCoords.first || y == yCoords.last else { continue }
                coords.append(vector_int2(x: Int32(x), y: Int32(y)))
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

// TODO: MOVE

extension NSValueTransformerName {
    static let moduleEntranceTransformer = NSValueTransformerName("ModuleEntranceTransformer")
    static let moduleEntranceSetTransformer = NSValueTransformerName("ModuleEntranceSetTransformer")
}

class ModuleEntrance: NSObject, Codable {
    
    static func registerTransformers() {
        ValueTransformer.setValueTransformer(JSONTransformer<ModuleEntrance>(), forName: .moduleEntranceTransformer)
        ValueTransformer.setValueTransformer(JSONTransformer<Set<ModuleEntrance>>(), forName: .moduleEntranceSetTransformer)
    }
    
    init(coordinate: CDPoint2, zAccess: Bool) {
        self.coordinate = coordinate
        self.zAccess = zAccess
        super.init()
    }
    
    let coordinate: CDPoint2
    let zAccess: Bool
}

extension ModuleEntrance {
    
    override var debugDescription: String {
        return String(describing: coordinate)
    }
}
