//
//  DeckSimulationViewController.swift
//  Carrier Game
//
//  Created by Sean G Young on 4/4/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit

// TODO NEXT: Latest problem is how do we update components/items/efficiency, etc on module instances from crewman work?
// - IDEA: Assign a property on modules which defines a set of identifiers which can be used to instantiate classes (via an enum?) and initialize each of these (or use static methods via a protocol?) and pass in crewman to have work done?

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
        
        // TODO: TEMPORARY
        let deckButton = UIButton(translatesAutoresizingMask: false)
        deckButton.setTitle("Next Deck", for: [])
        deckButton.setTitleColor(.blue, for: [])
        deckButton.addTarget(self, action: #selector(displayNextDeck), for: .touchUpInside)
        view.addSubview(deckButton)
        deckButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).activate()
        deckButton.trailingAnchor.constraint(equalToSystemSpacingAfter: view.layoutMarginsGuide.trailingAnchor, multiplier: 1.0).activate()

    }
    
    @objc private func displayNextDeck() {
        scene.displayDeck(entity: nextDeck())
    }

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
