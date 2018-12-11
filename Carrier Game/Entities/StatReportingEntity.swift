//
//  StatReportingEntity.swift
//  Carrier Game
//
//  Created by Sean G Young on 12/10/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import GameplayKit

class StatReportingEntity: GKEntity {
    
    // MARK: - Properties
    
    var providers = [StatsProvider]()
    var minInterval: TimeInterval = .hour
    
    private var intervalSinceReport: TimeInterval = 0
    
    // MARK: - Methods
    
    override func update(deltaTime seconds: TimeInterval) {
        intervalSinceReport += seconds
        guard intervalSinceReport >= minInterval else { return }
        makeReport()
        intervalSinceReport = 0
    }
    
    private func makeReport() {
        for provider in providers {
            let (name, stats) = provider.provideStats()
            // Just print current stats
            print("*** REPORT: \(name)")
            for stat in stats {
                print("** \(stat)")
            }
        }
    }
}
