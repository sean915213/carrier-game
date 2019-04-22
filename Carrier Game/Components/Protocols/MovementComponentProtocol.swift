//
//  MovementComponentProtocol.swift
//  Carrier Game
//
//  Created by Sean G Young on 12/7/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import GameKit

enum MovementResult { case completed, interrupted }

protocol MovementComponentProtocol where Self: GKComponent {
    
    // TODO: Make all these into a single struct?
    var path: [GKGridGraphNode3D]? { get }
    var remainingPath: [GKGridGraphNode3D]? { get }
    var callback: ((MovementResult) -> Void)? { get }
    
    func setPath(nodes: [GKGridGraphNode3D], completed: ((MovementResult) -> Void)?)
    func setPosition(_ position: GridPoint3)
}
