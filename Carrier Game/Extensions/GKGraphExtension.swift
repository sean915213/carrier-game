//
//  GKGraphExtension.swift
//  Carrier Game
//
//  Created by Sean G Young on 12/1/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import GameplayKit

extension GKGraph {
    
    func node(atPoint point: float3) -> GKGraphNode3D? {
        return nodes?.first(where: { ($0 as? GKGraphNode3D)?.position == point }) as? GKGraphNode3D
    }
}
