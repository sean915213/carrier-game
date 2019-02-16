//
//  DataSeeder.swift
//  Carrier Game
//
//  Created by Sean G Young on 10/26/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreData
import SGYSwiftUtility
import SpriteKit

private let seededDefaultsKey = "didSeed"

enum DataSeeder {
    
    // MARK: - Properties
    
    private static let logger = Logger(source: "DataSeeder")
    
    // MARK: - Methods
    
    static func seedIfRequired() {
        guard !UserDefaults.standard.bool(forKey: seededDefaultsKey) else {
            logger.logInfo("Data already seeded.")
            return
        }
        seedData()
    }
    
    static func removeAllData(completed: @escaping (Error?) -> Void) {
        NSPersistentContainer.model.destroyAllStores { error in
            if error == nil {
                // Reset defaults
                UserDefaults.standard.set(false, forKey: seededDefaultsKey)
            }
            // Execute completed
            completed(error)
        }
    }
    
    private static func seedData() {
        logger.logInfo("Seeding data.")
        // Seed on main queue currently
        let context = NSPersistentContainer.model.viewContext
        seedModuleBlueprints(using: context)
        seedShipBlueprints(using: context)
        seedTestShips(using: context)
        try! context.save()
        UserDefaults.standard.set(true, forKey: seededDefaultsKey)
        logger.logInfo("Data seeded.")
    }
    
    private static func seedModuleBlueprints(using context: NSManagedObjectContext) {
        // Bridge
        let bridgeModule = NSEntityDescription.insertNewObject(forEntityClass: ModuleBlueprint.self, into: context)
        bridgeModule.identifier = "bridge.small"
        bridgeModule.name = "Bridge (Small)"
        bridgeModule.size = CDPoint2(x: 5, y: 5)
        bridgeModule.mass = Measurement(value: 3, unit: UnitMass.kilograms)
        // Entrances
        bridgeModule.entrances.insert(ModuleEntrance(coordinate: CDPoint2(x: 2, y: 0), zAccess: false))
        
        // Lift
        let liftModule = NSEntityDescription.insertNewObject(forEntityClass: ModuleBlueprint.self, into: context)
        liftModule.identifier = "lift"
        liftModule.name = "Lift"
        liftModule.size = CDPoint2(x: 1, y: 1)
        liftModule.mass = Measurement(value: 0.5, unit: UnitMass.kilograms)
        // Entrances
        liftModule.entrances.insert(ModuleEntrance(coordinate: CDPoint2(x: 0, y: 0), zAccess: true))
        
        // Cooridor
        let cooridorModule = NSEntityDescription.insertNewObject(forEntityClass: ModuleBlueprint.self, into: context)
        cooridorModule.identifier = "cooridor.1x1"
        cooridorModule.name = "Cooridor (1x1)"
        cooridorModule.size = CDPoint2(x: 1, y: 1)
        cooridorModule.mass = Measurement(value: 0.5, unit: UnitMass.kilograms)
        // Entrances
        cooridorModule.entrances.insert(ModuleEntrance(coordinate: CDPoint2(x: 0, y: 0), zAccess: false))
        
        // Bulkhead
        let bulkheadModule = NSEntityDescription.insertNewObject(forEntityClass: ModuleBlueprint.self, into: context)
        bulkheadModule.identifier = "bulkhead.1x1"
        bulkheadModule.name = "Bulkhead (1x1)"
        bulkheadModule.size = CDPoint2(x: 1, y: 1)
        bulkheadModule.mass = Measurement(value: 1, unit: UnitMass.kilograms)
        
        // Cafe
        let cafeModule = NSEntityDescription.insertNewObject(forEntityClass: ModuleBlueprint.self, into: context)
        cafeModule.identifier = "cafe.small"
        cafeModule.name = "Cafeteria"
        cafeModule.size = CDPoint2(x: 5, y: 5)
        cafeModule.mass = Measurement(value: 1, unit: UnitMass.kilograms)
        // Entrances
        cafeModule.entrances.insert(ModuleEntrance(coordinate: CDPoint2(x: 0, y: 2), zAccess: true))
        cafeModule.entrances.insert(ModuleEntrance(coordinate: CDPoint2(x: 4, y: 2), zAccess: false))
        // Jobs
        // - Cook
        let cookJob = ModuleJobBlueprint.insertNew(into: context)
        cookJob.action = .cook
        cookJob.requiredCrewmen = 2
        cafeModule.jobs.insert(cookJob)
        // Needs
        // - Food
        let foodNeed = ModuleNeedBlueprint.insertNew(into: context)
        foodNeed.action = .food
        foodNeed.increaseFactor = ActionFactor.overShift * 4.0 // Require 1/4 a shift for full
        cafeModule.fulfilledNeeds.insert(foodNeed)
        
        // Engine
        let engineModule = NSEntityDescription.insertNewObject(forEntityClass: ModuleBlueprint.self, into: context)
        engineModule.identifier = "engine.small"
        engineModule.name = "Engine"
        engineModule.size = CDPoint2(x: 5, y: 5)
        engineModule.mass = Measurement(value: 1, unit: UnitMass.kilograms)
        // Attributes
        engineModule.attributes = [ModuleAttribute.engineThrust: 100]
        engineModule.entrances.insert(ModuleEntrance(coordinate: CDPoint2(x: 4, y: 2), zAccess: false))
        // Jobs
        // - Engineer
        let engineJob = ModuleJobBlueprint.insertNew(into: context)
        engineJob.action = .engineer
        engineJob.requiredCrewmen = 2
        engineModule.jobs.insert(engineJob)
        
        // Quarters
        let quartersModule = NSEntityDescription.insertNewObject(forEntityClass: ModuleBlueprint.self, into: context)
        quartersModule.identifier = "quarters.small"
        quartersModule.name = "Quarters"
        quartersModule.size = CDPoint2(x: 5, y: 5)
        quartersModule.mass = Measurement(value: 1, unit: UnitMass.kilograms)
        // Attributes
        quartersModule.attributes = [ModuleAttribute.crewSupported: 4]
        // Entrances
        for point in CDPoint2.map(from: CGRect(x: 0, y: 2, width: 5, height: 1)) {
            // TODO: SHOULD NOT BE ADDING ENTIRE LINE
            quartersModule.entrances.insert(ModuleEntrance(coordinate: point, zAccess: false))
        }
        quartersModule.entrances.insert(ModuleEntrance(coordinate: CDPoint2(x: 0, y: 2), zAccess: true))
        // Needs
        // - Sleep
        let sleepNeed = ModuleNeedBlueprint.insertNew(into: context)
        sleepNeed.action = .sleep
        sleepNeed.increaseFactor = ActionFactor.overShift
        quartersModule.fulfilledNeeds.insert(sleepNeed)
        
        // Weapon
        let weaponModule = NSEntityDescription.insertNewObject(forEntityClass: ModuleBlueprint.self, into: context)
        weaponModule.identifier = "weapon.laser.small"
        weaponModule.name = "Laser"
        weaponModule.size = CDPoint2(x: 3, y: 3)
        weaponModule.mass = Measurement(value: 1, unit: UnitMass.kilograms)
        // Entrances
        weaponModule.entrances.insert(ModuleEntrance(coordinate: CDPoint2(x: 0, y: 1), zAccess: false))
        // Jobs
        // - Weapon
        let weaponJob = ModuleJobBlueprint.insertNew(into: context)
        weaponJob.action = .weapon
        weaponJob.requiredCrewmen = 1
        weaponModule.jobs.insert(weaponJob)
    }
    
    private static func seedShipBlueprints(using context: NSManagedObjectContext) {
        seedTestBlueprint1(using: context)
        seedTestBlueprint2(using: context)
    }
    
    private static func seedTestShips(using context: NSManagedObjectContext) {
        seedTestShip1(using: context)
        seedTestShip2(using: context)
    }
}

extension DataSeeder {
    
    fileprivate static func seedTestBlueprint1(using context: NSManagedObjectContext) {
        // Make ship
        let ship = ShipBlueprint.insertNew(into: context)
        ship.identifier = "ship.test"
        ship.name = "Test Ship 1"
        
        // Add decks
        // 0 - MAIN DECK
        let deck0 = DeckBlueprint.insertNew(into: context, on: ship, at: 0)
        deck0.name = "Basic Deck"
        deck0.ship = ship
        // Place on ship
        ship.decks.insert(deck0)
        
        // 1 - CREW DECK
        let deck1 = DeckBlueprint.insertNew(into: context, on: ship, at: 1)
        deck1.name = "Basic Deck"
        deck1.ship = ship
        // Place on ship
        ship.decks.insert(deck1)
        
        // Add modules
        // DECK 0
        // - Engine
//        deck0.placeModule(try! ModuleBlueprint.entityWithIdentifier("engine.small", using: context)!, at: CDPoint2(x: 0, y: 0))
        
        let engine = ModulePlacement.insertNew(into: context)
        engine.blueprint = try! ModuleBlueprint.entityWithIdentifier("engine.small", using: context)!
        engine.origin = CDPoint2(x: 0, y: 0)
        deck0.modulePlacements.insert(engine)
        
        
        // - Weapon
        let weapon = ModulePlacement.insertNew(into: context)
        weapon.blueprint = try! ModuleBlueprint.entityWithIdentifier("weapon.laser.small", using: context)!
        weapon.origin = CDPoint2(x: 10, y: 1)
        deck0.modulePlacements.insert(weapon)
        // - Cafe
        let cafe = ModulePlacement.insertNew(into: context)
        cafe.blueprint = try! ModuleBlueprint.entityWithIdentifier("cafe.small", using: context)!
        cafe.origin = CDPoint2(x: 5, y: 0)
        deck0.modulePlacements.insert(cafe)
        // - Bulkhead // TEST
        let bulkhead = ModulePlacement.insertNew(into: context)
        bulkhead.blueprint = try! ModuleBlueprint.entityWithIdentifier("bulkhead.1x1", using: context)!
        bulkhead.origin = CDPoint2(x: -1, y: 0)
        deck0.modulePlacements.insert(bulkhead)
        // - Cooridor // TEST
        let cooridor = ModulePlacement.insertNew(into: context)
        cooridor.blueprint = try! ModuleBlueprint.entityWithIdentifier("cooridor.1x1", using: context)!
        cooridor.origin = CDPoint2(x: -2, y: 0)
        deck0.modulePlacements.insert(cooridor)
        
        // DECK 1
        // - Quarters
        let quarters = ModulePlacement.insertNew(into: context)
        quarters.blueprint = try! ModuleBlueprint.entityWithIdentifier("quarters.small", using: context)!
        quarters.origin = CDPoint2(x: 5, y: 0)
        deck1.modulePlacements.insert(quarters)
    }
    
    fileprivate static func seedTestBlueprint2(using context: NSManagedObjectContext) {
        // Make ship
        let ship = ShipBlueprint.insertNew(into: context)
        ship.identifier = "ship.test2"
        ship.name = "Test Ship 2"
        
        // Add decks
        // 0 - MAIN DECK
        let deck0 = DeckBlueprint.insertNew(into: context, on: ship, at: 0)
        deck0.name = "Basic Deck"
        deck0.ship = ship
        // Place on ship
        ship.decks.insert(deck0)
        
        // Add modules
        // - Bridge
        let bridge = try! deck0.placeModule(withIdentifier: "bridge.small", at: CDPoint2(x: 0, y: 0))
        bridge.rotation = .quarter
        // - Cooridors
        for point in [CDPoint2(x: 1, y: 2), CDPoint2(x: 2, y: 2), CDPoint2(x: 3, y: 2), CDPoint2(x: 4, y: 2), CDPoint2(x: 4, y: 3)] {
            try! deck0.placeModule(withIdentifier: "cooridor.1x1", at: point)
        }
        // - Laser
        let laser = try! deck0.placeModule(withIdentifier: "weapon.laser.small", at: CDPoint2(x: 3, y: 1))
        laser.rotation = .threeQuarter
        // - Lift
        try! deck0.placeModule(withIdentifier: "lift", at: CDPoint2(x: 4, y: 4))
        
        // 1 - BELOW DECK
        let deck1 = DeckBlueprint.insertNew(into: context, on: ship, at: 1)
        deck1.name = "Below Deck"
        deck1.ship = ship
        // Place on ship
        ship.decks.insert(deck1)

        // Add modules
        // - Lift
        try! deck1.placeModule(withIdentifier: "lift", at: CDPoint2(x: 4, y: 4))
        // - Cafe
        try! deck1.placeModule(withIdentifier: "cafe.small", at: CDPoint2(x: -1, y: 2))
        // - Quarters
        try! deck1.placeModule(withIdentifier: "quarters.small", at: CDPoint2(x: 5, y: 2))
    }
}

extension DataSeeder {
    
    fileprivate static func seedTestShip1(using context: NSManagedObjectContext) {
        // Insert ship
        let blueprint = try! ShipBlueprint.entityWithIdentifier("ship.test", using: context)!
        let ship = ShipInstance.insertNew(into: context, using: blueprint)
        ship.name = "Test Ship 1"
        // - Get list of jobs
        let allJobs = ship.allModules.flatMap({ $0.jobs })
        
        // Add crewmen to only deck
        let crew1 = CrewmanInstance.insertNew(into: context)
        crew1.name = "Crew 1"
        crew1.position = CDPoint3(x: 6, y: 1, z: 0)
        crew1.shift = .second
        ship.crewmen.insert(crew1)
        // Job (Weapon)
        crew1.job = allJobs.first(where: { $0.blueprint.action == .weapon })!
        // Needs
        // - Sleep
        let sleepNeed1 = CrewmanNeed.insertNew(into: context)
        sleepNeed1.action = .sleep
        sleepNeed1.priority = .normal
        sleepNeed1.decayFactor = ActionFactor.overShift / 2 // Should decay over 2 shifts shift
        crew1.needs.insert(sleepNeed1)
        // - Food
        let foodNeed1 = CrewmanNeed.insertNew(into: context)
        foodNeed1.action = .food
        foodNeed1.priority = .normal
        foodNeed1.decayFactor = ActionFactor.overShift // Should decay over a single shift
        crew1.needs.insert(foodNeed1)
        
        let crew2 = CrewmanInstance.insertNew(into: context)
        crew2.name = "Crew 2"
        crew2.position = CDPoint3(x: 2, y: 2, z: 0)
        crew2.shift = .second
        ship.crewmen.insert(crew2)
        // Job (Engineer)
        crew2.job = allJobs.first(where: { $0.blueprint.action == .engineer })!
        // Needs
        // - Sleep
        let sleepNeed2 = CrewmanNeed.insertNew(into: context)
        sleepNeed2.action = .sleep
        sleepNeed2.priority = .normal
        sleepNeed2.decayFactor = ActionFactor.overShift // Should decay over a single shift
        crew2.needs.insert(sleepNeed2)
        // - Food
        let foodNeed2 = CrewmanNeed.insertNew(into: context)
        foodNeed2.action = .food
        foodNeed2.priority = .normal
        foodNeed2.decayFactor = ActionFactor.overShift / 2 // Should decay over 2 shifts
        crew2.needs.insert(foodNeed2)
    }
    
    fileprivate static func seedTestShip2(using context: NSManagedObjectContext) {
        // Insert ship
        let blueprint = try! ShipBlueprint.entityWithIdentifier("ship.test2", using: context)!
        let ship = ShipInstance.insertNew(into: context, using: blueprint)
        ship.name = "Test Ship 2"
        // - Get list of jobs
        let allJobs = ship.allModules.flatMap({ $0.jobs })
        
        // CREWMEN
        let crew1 = CrewmanInstance.insertNew(into: context)
        crew1.name = "Crew 1"
        crew1.position = CDPoint3(x: -2, y: 2, z: 0)
        crew1.shift = .second
        ship.crewmen.insert(crew1)
        // Job (Weapon)
        crew1.job = allJobs.first(where: { $0.blueprint.action == .weapon })!
        // Needs
        // - Sleep
        let sleepNeed1 = CrewmanNeed.insertNew(into: context)
        sleepNeed1.action = .sleep
        sleepNeed1.priority = .normal
        sleepNeed1.decayFactor = ActionFactor.overShift / 2 // Should decay over 2 shifts shift
        crew1.needs.insert(sleepNeed1)
        // - Food
        let foodNeed1 = CrewmanNeed.insertNew(into: context)
        foodNeed1.action = .food
        foodNeed1.priority = .normal
        foodNeed1.decayFactor = ActionFactor.overShift // Should decay over a single shift
        crew1.needs.insert(foodNeed1)
        
        let crew2 = CrewmanInstance.insertNew(into: context)
        crew2.name = "Crew 2"
        crew2.position = CDPoint3(x: -3, y: 3, z: 0)
        crew2.shift = .second
        ship.crewmen.insert(crew2)
        // Job (Engineer)
        crew2.job = allJobs.first(where: { $0.blueprint.action == .cook })!
        // Needs
        // - Sleep
        let sleepNeed2 = CrewmanNeed.insertNew(into: context)
        sleepNeed2.action = .sleep
        sleepNeed2.priority = .normal
        sleepNeed2.decayFactor = ActionFactor.overShift // Should decay over a single shift
        crew2.needs.insert(sleepNeed2)
        // - Food
        let foodNeed2 = CrewmanNeed.insertNew(into: context)
        foodNeed2.action = .food
        foodNeed2.priority = .normal
        foodNeed2.decayFactor = ActionFactor.overShift / 2 // Should decay over 2 shifts
        crew2.needs.insert(foodNeed2)
    }
}

// TODO: MOVE TO UTILITY
//extension NamedManagedObject {
//    
//    static func insertNew(into context: NSManagedObjectContext) -> Self {
//        return NSEntityDescription.insertNewObject(forEntityClass: Self.self, into: context)
//    }
//}
