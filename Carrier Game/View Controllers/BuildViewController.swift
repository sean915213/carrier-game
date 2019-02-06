//
//  BuildViewController.swift
//  Carrier Game
//
//  Created by Sean G Young on 10/17/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit
import SceneKit

// TODO: Seems like an old proof of concept

class BuildViewController: UIViewController {
    
    // MARK: - Initialization
    
    // MARK: - Properties
    
    private let scene = SCNScene()
    
    private var sceneView: SCNView {
        return view as! SCNView
    }
    
    // MARK: - Methods
    
    override func loadView() {
        view = SCNView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        
        let geometry = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 0)
        geometry.firstMaterial!.diffuse.contents = UIColor.red
        let node = SCNNode(geometry: geometry)
        scene.rootNode.addChildNode(node)
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 50)
        
        print("&& LOADED")
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
