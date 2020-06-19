import UIKit
import SceneKit
import ARKit

class MainViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    var start: CGPoint?
    var end: CGPoint?
    var motherBallNode: SCNNode!
    let ballRadius: Float = 0.02
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(panGesture:)))
        sceneView.addGestureRecognizer(panGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @objc func handlePan(panGesture: UIPanGestureRecognizer) {
        let view = panGesture.view
        
        if panGesture.state == .began {
            start = panGesture.translation(in: view)
        }
        
        if panGesture.state == .ended {
            end = panGesture.translation(in: view)
            
            guard let startPoint = start, let endPoint = end else { return }
            
            guard let start3D = sceneView.hitTest(startPoint, types: .estimatedHorizontalPlane).first,
                let end3D = sceneView.hitTest(endPoint, types: .estimatedHorizontalPlane).first else { return }
            
            let end3DTranslation = end3D.worldTransform.columns.3
            let start3DTranslation = start3D.worldTransform.columns.3
            motherBallNode.runAction(SCNAction.moveBy(x: CGFloat(end3DTranslation.x - start3DTranslation.x),
                y: CGFloat(end3DTranslation.y - start3DTranslation.y),
                z: CGFloat(end3DTranslation.z - start3DTranslation.z),
                duration: 2))

//            print("start: \(startPoint.x) \(startPoint.y)")
//            print("end: \(endPoint.x) \(endPoint.y))")
//
//            print("\(start3D.worldTransform.columns.3)")
//            print("\(end3D.worldTransform.columns.3)")
        }
        
    }
}

extension MainViewController: ARSCNViewDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.green
        plane.materials = [planeMaterial]
        
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        planeNode.geometry = plane
        
        node.addChildNode(planeNode)
        
        let motherBall = SCNSphere(radius: CGFloat(ballRadius))
        let ballMaterial = SCNMaterial()
        ballMaterial.diffuse.contents = UIColor.red
        motherBall.materials = [ballMaterial]
        
        motherBallNode = SCNNode()
        motherBallNode.position = SCNVector3(planeAnchor.center.x, ballRadius, planeAnchor.center.z)
        motherBallNode.geometry = motherBall
        
        node.addChildNode(motherBallNode)
    }
}
