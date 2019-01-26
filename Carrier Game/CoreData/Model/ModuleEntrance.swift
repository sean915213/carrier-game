//
//  ModuleEntrance.swift
//  Carrier Game
//
//  Created by Sean G Young on 1/26/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import Foundation

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
        return String(describing: coordinate) + ", z: \(zAccess)"
    }
}
