//
//  ModuleJobInstance.swift
//  Carrier Game
//
//  Created by Sean G Young on 12/3/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit
import CoreData

class ModuleJobInstance: NSManagedObject {
    
    @NSManaged var module: ModuleInstance
    @NSManaged var blueprint: ModuleJobBlueprint
    @NSManaged var assignedCrewmen: Set<CrewmanInstance>
}
