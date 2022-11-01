//
//  ViewController.swift
//  BasicARApp
//
//  Created by Michele Manniello on 01/11/22.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        setupARView()
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
//    MARK: Setup Methods
    
    func setupARView(){
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal,.vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
    }
    
//    MARK: OBject Placement
    @objc
    func handleTap(recognizer:UITapGestureRecognizer){
        let location = recognizer.location(in: arView)
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        if let firstResult = results.first{
            let anchor = ARAnchor(name: "LemonMeringuePie", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        }else{
            print("object placement fallied- could't find surface")
        }
    }
    
    func placeObject(named entityName:String, for anchor:ARAnchor){
        let entity = try!  ModelEntity.loadModel(named: entityName)
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation,.translation,.scale,], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
        
    }
}

extension ViewController:ARSessionDelegate{
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let ancorName = anchor.name,ancorName == "LemonMeringuePie"{
                placeObject(named: ancorName,for: anchor)
            }
        }
    }
}
