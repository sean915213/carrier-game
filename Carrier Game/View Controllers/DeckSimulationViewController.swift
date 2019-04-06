//
//  DeckSimulationViewController.swift
//  Carrier Game
//
//  Created by Sean G Young on 4/4/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit

// TODO: Add simulation logic that was commented out. Also will need a new class of DeckScene.

class DeckSimulationViewController: Deck2DViewController<Deck2DSimulationScene> {
    
    // MARK: - Initialization
    
    init(ship: ShipInstance) {
        super.init(scene: Deck2DSimulationScene(ship: ship, size: CGSize(width: 50, height: 50)), ship: ship.blueprint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // TAP RECOGNIZE LOGIC
    
    // Find associated crewman
//    let nodes = scene.nodes(at: point)
//    let crewmen = shipEntity.crewmanEntities.filter({ nodes.contains($0.rootNode) })
//    for crewman in crewmen {
//    // Add or remove from stat report on scene
//    if let index = scene.reporter.providers.firstIndex(where: { $0 as? CrewmanEntity == crewman }) {
//    scene.reporter.providers.remove(at: index)
//    } else {
//    scene.reporter.providers.append(crewman)
//    }
//    }
}
