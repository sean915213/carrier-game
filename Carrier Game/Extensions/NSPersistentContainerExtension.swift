//
//  NSPersistentContainerExtension.swift
//  Carrier Game
//
//  Created by Sean G Young on 10/26/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData

private let modelContainer = NSPersistentContainer(name: "Model")

extension NSPersistentContainer {
    static var model: NSPersistentContainer { return modelContainer }
}
