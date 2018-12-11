//
//  StatsProvider.swift
//  Carrier Game
//
//  Created by Sean G Young on 12/10/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation

struct Stat: CustomDebugStringConvertible {
    let name: String
    let value: Any
    
    var debugDescription: String {
        return "\(name): \(value)"
    }
}

protocol StatsProvider {
    func provideStats() -> (name: String, stats: [Stat])
}
