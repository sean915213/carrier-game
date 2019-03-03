//
//  CrewmanInstance.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/14/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit
import CoreData
import GameplayKit

@objc enum CrewmanShift: Int16, CustomDebugStringConvertible {
    
    static let length = Measurement(value: 8, unit: UnitDuration.hours)
    
    case first, second, third
    
    init?(date: Date) {
        // Get the hour of the current date
        // TODO: SHOULD NOT BE USING THE CURRENT CALENDAR.
        let hour = Double(Calendar.current.component(.hour, from: date))
        // Divide by the shift length and floor the result
        let shiftValue = floor(hour / CrewmanShift.length.value)
        // Try creating an instance from this value
        guard let shift = CrewmanShift(rawValue: Int16(shiftValue)) else { return nil }
        self = shift
    }
    
    var debugDescription: String {
        return String(rawValue + 1)
    }
}

class CrewmanInstance: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var position: CDPoint3
    @NSManaged var shift: CrewmanShift

    @NSManaged var ship: ShipInstance
    @NSManaged var job: ModuleJobInstance?
    @NSManaged var needs: Set<CrewmanNeed>
}
