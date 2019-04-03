//
//  ModuleEntity.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/12/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import SpriteKit
import GameplayKit

class ModuleEntity: GKEntity {
    
    // MARK: - Initialization
    
    // TODO: SHOULD PROBABLY JUST PASS AN INSTANCE. THERE AREN'T SITUATIONS THAT EXIST NOW WHERE IT'S NOT AVAILABLE
    
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
    private(set) lazy var mainNodeComponent: ModuleEntityNodeComponent2D = {
        let component = ModuleEntityNodeComponent2D(placement: placement)
        addComponent(component)
        return component
    }()
    
    // MARK: - Methods
}
