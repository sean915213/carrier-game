//
//  CrewmanNeed.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/14/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit
import CoreData

class CrewmanNeed: NSManagedObject {

    @NSManaged var decayFactor: Double
    @NSManaged var value: Double
    @NSManaged var action: Action
    @NSManaged var priority: ActionPriority
    
    @NSManaged var crewman: CrewmanInstance
}
