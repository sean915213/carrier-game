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
    
    static let length = 8
    
    case first, second, third
    
    init?(date: Date) {
        let hour = Calendar.current.component(.hour, from: date)
        // Divide by length of a shift and floor for result
        guard let shift = CrewmanShift(rawValue: Int16(floor(Double(hour) / Double(CrewmanShift.length)))) else { return nil }
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
