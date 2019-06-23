//
//  SleepNeedTask.swift
//  Carrier Game
//
//  Created by Sean G Young on 6/23/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import Foundation

class SleepNeedTask: CrewmanNeedTask {
    
    // MARK: - Initialization
    
    override init(crewman: CrewmanEntity, need: CrewmanNeed) {
        assert(need.action == .sleep, "SleepNeedTask initialized with invalid need action: \(need.action).")
        super.init(crewman: crewman, need: need)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    // MARK: - Methods
    
    override func endTaskControl() {
        print("++ ENDED SLEEP TASK AFTER \(controlDuration!.converted(to: .minutes).value) MINUTES. VALUE: \(need.value)")
        super.endTaskControl()
    }
    
    override func calculatePriority() -> TaskPriority {
        // Sleep is always required at 0 value
        if need.value <= 0 { return .required }
        
        // TODO: TESTING MINIMUM TIME
        if let duration = controlDuration, duration < Measurement(value: 4, unit: UnitDuration.hours), !crewman.isOnShift {
            return .required
        }
        
        // Use custom priority curve for sleep need
        // Quickly increase priority at lower values
        if need.value <= 10 { return .urgent }
        if need.value <= 20 { return .high }
        if need.value <= 60 { return .low }
        return .none
    }
}
