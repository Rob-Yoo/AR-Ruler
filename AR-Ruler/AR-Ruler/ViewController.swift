//
//  ViewController.swift
//  AR-Ruler
//
//  Created by Jinyoung Yoo on 2023/07/13.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes: [SCNNode] = []
    var textNode: SCNNode = SCNNode()
    
    
// MARK: - UIViewController Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
// MARK: - UIResponder Override Methods

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchLocation = touches.first?.location(in: sceneView) else { return }
        
        guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any) else {
            return
        }
        
        let rayCastResults = sceneView.session.raycast(query)
        
        if let result = rayCastResults.first {
            addDot(at: result)
        }
    }
    
// MARK: - Feature Methods

    func addDot(at raycastResult: ARRaycastResult) {
        
        if self.dotNodes.count >= 2 {
            reset()
        }

        let dotGeometry = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode()
        dotNode.position = SCNVector3(
            x: raycastResult.worldTransform.columns.3.x,
            y: raycastResult.worldTransform.columns.3.y,
            z: raycastResult.worldTransform.columns.3.z)
        dotNode.geometry = dotGeometry
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        self.dotNodes.append(dotNode)

        if self.dotNodes.count >= 2 {
            calculateDistance(dotNodes: dotNodes)
        }
    }
    
    func reset() {
        for node in dotNodes {
            node.removeFromParentNode()
        }
        self.dotNodes.removeAll()
    }
    
    func calculateDistance(dotNodes: [SCNNode]) {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2))
        update3DText(text: "\(distance)", at: end.position)
    }
    
    func update3DText(text distance: String, at position: SCNVector3) {
        
        self.textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: distance, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.02, position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        sceneView.scene.rootNode.addChildNode(textNode)
        self.textNode = textNode
    }
}
