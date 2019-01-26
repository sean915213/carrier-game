//
//  ModuleAttribute.swift
//  Carrier Game
//
//  Created by Sean G Young on 1/26/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import Foundation

typealias ModuleAttribute = String
extension ModuleAttribute {
    static let crewSupported = "crew_supported"
    static let engineThrust = "engine_thrust"
}

extension Array where Element == [ModuleAttribute: Double] {
    
    func combined() -> [ModuleAttribute: Double] {
        var allAttributes = [ModuleAttribute: Double]()
        for attributes in self {
            allAttributes.merge(attributes, uniquingKeysWith: +)
        }
        return allAttributes
    }
}
