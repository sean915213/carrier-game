//
//  Action.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/14/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation

// TODO: NOT ADDED TO COREDATA MODEL

@objc enum Action: Int16, CustomDebugStringConvertible {
    case sleep, weapon, engineer, cook, food
    
    var debugDescription: String {
        switch self {
        case .sleep: return "Sleep"
        case .weapon: return "Weapon"
        case .engineer: return "Engineer"
        case .cook: return "Cook"
        case .food: return "Food"
        }
    }
}

@objc enum ActionPriority: Int16 { case low, normal, high  }

typealias ActionFactor = Double

extension ActionFactor {
    
    static let overShift = 100.0 / Double(CrewmanShift.length * (60 * 60))
}
