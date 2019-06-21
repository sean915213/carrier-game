//
//  Configuration.swift
//  Carrier Game
//
//  Created by Sean G Young on 5/6/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import Foundation
import CoreGraphics

enum Configuration {
    
//    static let gameSecondsPerRealSecond: Double = ((60 * 60) / 3.0) * 2
    static let gameSecondsPerRealSecond: Double = 240
    
    // NOTE: A person's avg walking speed reduced slightly
    static let crewmanMovementSpeed = Measurement(value: 1.3, unit: UnitSpeed.metersPerSecond)
    
}
