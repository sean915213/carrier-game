//
//  ShipSceneController.swift
//  Carrier Game
//
//  Created by Sean G Young on 4/6/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit
import SceneKit

class ShipSceneController: UIViewController {
    
    // MARK: - Initialization
    
    init(ship: ShipInstance) {
        self.ship = ship
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let ship: ShipInstance
    
    private lazy var shipEntity: ShipEntity = {
        return ShipEntity(blueprint: ship.blueprint)
    }()
    
    private lazy var scene: SCNScene = {
        let scene = SCNScene()
        return scene
    }()
    
    private var sceneView: SCNView {
        return view as! SCNView
    }
    
    // MARK: - Methods
    
    override func loadView() {
        let sceneView = SCNView()
        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = true
        view = sceneView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        
        // TODO: TEST
        let shipNode = SCNNode(geometry: nil)
        scene.rootNode.addChildNode(shipNode)
        for deckEntity in shipEntity.orderedDeckEntities {
//            guard deckEntity == shipEntity.orderedDeckEntities.first else { continue }
            
            let deckNode = SCNNode(geometry: nil)
            deckNode.position = SCNVector3(0, 0, Int(deckEntity.blueprint.position))
            shipNode.addChildNode(deckNode)
            for moduleEntity in deckEntity.moduleEntities {
                let moduleGeometry = SCNBox(width: moduleEntity.blueprint.size.x, height: moduleEntity.blueprint.size.y, length: 1, chamferRadius: 0)
                let moduleNode = SCNNode(geometry: moduleGeometry)
                
                if moduleEntity.blueprint.identifier == "cooridor.1x1" {
                    moduleGeometry.firstMaterial!.diffuse.contents = UIColor.green
                } else if moduleEntity.blueprint.identifier == "lift" {
                    moduleGeometry.firstMaterial!.diffuse.contents = UIColor.yellow
                }
                
                let pivotXform = SCNMatrix4MakeTranslation((Float(-moduleEntity.blueprint.size.x) / 2.0) + 0.5, (Float(-moduleEntity.blueprint.size.y) / 2.0) + 0.5, -0.5)
                moduleNode.pivot = pivotXform
                
                
//                let moduleNode = SCNNode(geometry: moduleGeometry)
                moduleNode.eulerAngles = SCNVector3(x: 0, y: 0, z: moduleEntity.placement.rotation.radians)
//                moduleNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: moduleEntity.placement.rotation.radians)
                moduleNode.position = SCNVector3(x: Float(moduleEntity.placement.origin.x), y: Float(moduleEntity.placement.origin.y), z: 0)

                print("&& MODULE: \(moduleEntity.blueprint.identifier). POS: \(moduleNode.position). DECK POS: \(deckNode.position)")
                
                deckNode.addChildNode(moduleNode)
            }
        }
        
//        let squareNode = SCNNode(geometry: SCNBox(width: 3, height: 3, length: 3, chamferRadius: 0))
//        scene.rootNode.addChildNode(squareNode)
        
        print("&& ADDED CHILD")
    }
    
    private func setupScene() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        scene.rootNode.addChildNode(cameraNode)
        // Assign to view
        sceneView.scene = scene
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
