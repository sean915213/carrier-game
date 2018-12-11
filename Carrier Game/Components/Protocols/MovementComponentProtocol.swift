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

protocol MovementComponentProtocol {
    
    // TODO: Make all these into a single struct?
    var path: [GKGraphNode3D]? { get }
    var remainingPath: [GKGraphNode3D]? { get }
    var callback: ((MovementResult) -> Void)? { get }
    
    func setPath(nodes: [GKGraphNode3D], completed: ((MovementResult) -> Void)?)
}
