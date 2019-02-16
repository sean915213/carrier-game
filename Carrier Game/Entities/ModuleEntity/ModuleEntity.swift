//
//  ModuleEntity.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/12/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import SpriteKit
import GameplayKit

// TODO: NEXT- Added observer that updates node position based on change of ModulePlacement. But should this entity even be responsible? Make node component responsible. Then the added editing node component (assumed solution) can do the same rather than this entity having to know about all possible relevant components.
// BUT- Does that matter? Won't editing node component just add and manage nodes on the main node?
// BUT THEN- yeah it will but how will it know the information required to modify individual tiles as valid or invalid??? (larger question anyway)

class ModuleEntity: GKEntity {
    
    // MARK: - Initialization
    
    init(placement: ModulePlacement) {
        self.placement = placement
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let placement: ModulePlacement
    var blueprint: ModuleBlueprint { return placement.blueprint }
    
    // TODO: THINGS TO DO WHEN THIS IS ASSIGNED?
    var instance: ModuleInstance?
    
    // TODO: Should be a node component that adheres to protocol since entity should not care whether it's in 2D or 3D environment?
    private(set) lazy var mainNodeComponent: GKSKNodeComponent = {
        let component = ModuleEntityNodeComponent2D()
        addComponent(component)
        return component
    }()
    
    // MARK: - Methods
}
