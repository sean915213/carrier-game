//
//  ModuleNeedBlueprint.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/14/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit
import CoreData

class ModuleNeedBlueprint: NSManagedObject {
    
    @NSManaged var action: Action
    @NSManaged var increaseFactor: Double
    
    @NSManaged var module: ModuleBlueprint
}
