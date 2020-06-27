import UIKit
import SceneKit
import ARKit

enum WallType {
    case negativeZ
    case positiveZ
    case negativeX
    case positiveX
}

class MainViewController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var resetButton: UIButton!
    
    var start: CGPoint?
    var end: CGPoint?
    var motherBallNode: BallNode!
    let ballRadius: Float = 0.02
    var worldRotation: Float = 0
    
    let tableWidth: CGFloat = 0.5
    let tableLength: CGFloat = 0.3
    let holeLength: CGFloat = 0.03
    
    var planeNode: SCNNode?
    var planeAnchor: ARPlaneAnchor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(panGesture:)))
        sceneView.addGestureRecognizer(panGesture)
        
        sceneView.scene.physicsWorld.contactDelegate = self
        
        resetButton.isEnabled = false
        resetButton.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        reset()
    }
    
    private func reset() {
        planeNode!.childNodes.forEach { node in
            if node is BallNode {
                node.removeFromParentNode()
            }
        }
            
        setupMotherBall(planeAnchor: planeAnchor!, node: planeNode!)
        setupTargetBall(planeAnchor: planeAnchor!, node: planeNode!)
    }
    
    @objc func handlePan(panGesture: UIPanGestureRecognizer) {
        let view = panGesture.view
        
        if panGesture.state == .began {
            start = panGesture.translation(in: view)
        }
        
        if panGesture.state == .ended {
            end = panGesture.translation(in: view)
            
            guard let startPoint = start, let endPoint = end else { return }
            
            guard let start3D = sceneView.hitTest(startPoint, types: .existingPlane).first,
                let end3D = sceneView.hitTest(endPoint, types: .existingPlane).first else { return }
            
            let end3DTranslation = end3D.worldTransform.columns.3
            let start3DTranslation = start3D.worldTransform.columns.3
            let startToEnd = SCNVector3(end3DTranslation.x - start3DTranslation.x,
                                        0,
                                        end3DTranslation.z - start3DTranslation.z)
            
            let column0 = start3D.worldTransform.columns.0
            worldRotation = atan(column0[2] / column0[0])
            let ballDirection = startToEnd.normalized.rotationByY(degree: -worldRotation)
            let speed = startToEnd.length

            motherBallNode.runAction(SCNAction.moveBy(x: CGFloat(ballDirection.x * speed * 3),
                                                      y: 0,
                                                      z: CGFloat(ballDirection.z * speed * 3),
                                                      duration: 3), forKey: ObjectCategory.motherBall.nodeName)
            motherBallNode.moved(ballSpeed: speed, ballDirection: ballDirection)
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
        
        DispatchQueue.main.async {
            self.resetButton.isEnabled = true
        }
        self.planeNode = node
        self.planeAnchor = planeAnchor
        
        setupPlane(planeAnchor: planeAnchor, node: node)
        setupMotherBall(planeAnchor: planeAnchor, node: node)
        setupTargetBall(planeAnchor: planeAnchor, node: node)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
}

extension MainViewController {
    private func setupPlane(planeAnchor: ARPlaneAnchor, node: SCNNode) {
        let plane = SCNPlane(width: tableWidth, height: tableLength)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.green
        plane.materials = [planeMaterial]
        
        let planeNode = SCNNode()
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        planeNode.position = SCNVector3(planeAnchor.center.x,
                                        0,
                                        planeAnchor.center.z)
        planeNode.geometry = plane
        
        node.addChildNode(planeNode)
        
        //setup holes
        let holeNegativeXNegativeZ = SCNPlane(width: holeLength, height: holeLength)
        let holeNegativeXNegativeZMaterial = SCNMaterial()
        holeNegativeXNegativeZMaterial.diffuse.contents = UIColor.black
        holeNegativeXNegativeZ.materials = [holeNegativeXNegativeZMaterial]
        
        let holeNegativeXNegativeZNode = SCNNode()
        holeNegativeXNegativeZNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        holeNegativeXNegativeZNode.position = SCNVector3(planeAnchor.center.x - Float(tableWidth) / 2 + Float(holeLength) / 2,
                                                         0.001,
                                                         planeAnchor.center.z - Float(tableLength) / 2 + Float(holeLength) / 2)
        holeNegativeXNegativeZNode.geometry = holeNegativeXNegativeZ
        node.addChildNode(holeNegativeXNegativeZNode)
        
        let holeNegativeXPositiveZ = SCNPlane(width: holeLength, height: holeLength)
        let holeNegativeXPositiveZMaterial = SCNMaterial()
        holeNegativeXPositiveZMaterial.diffuse.contents = UIColor.black
        holeNegativeXPositiveZ.materials = [holeNegativeXPositiveZMaterial]
        
        let holeNegativeXPositiveZNode = SCNNode()
        holeNegativeXPositiveZNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        holeNegativeXPositiveZNode.position = SCNVector3(planeAnchor.center.x - Float(tableWidth) / 2 + Float(holeLength) / 2,
                                                         0.001,
                                                         planeAnchor.center.z + Float(tableLength) / 2 - Float(holeLength) / 2)
        holeNegativeXPositiveZNode.geometry = holeNegativeXPositiveZ
        node.addChildNode(holeNegativeXPositiveZNode)
        
        let holePositiveXNegativeZ = SCNPlane(width: holeLength, height: holeLength)
        let holePositiveXNegativeZMaterial = SCNMaterial()
        holePositiveXNegativeZMaterial.diffuse.contents = UIColor.black
        holePositiveXNegativeZ.materials = [holePositiveXNegativeZMaterial]
        
        let holePositiveXNegativeZNode = SCNNode()
        holePositiveXNegativeZNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        holePositiveXNegativeZNode.position = SCNVector3(planeAnchor.center.x + Float(tableWidth) / 2 - Float(holeLength) / 2,
                                                         0.001,
                                                         planeAnchor.center.z - Float(tableLength) / 2 + Float(holeLength) / 2)
        holePositiveXNegativeZNode.geometry = holePositiveXNegativeZ
        node.addChildNode(holePositiveXNegativeZNode)
        
        let holePositiveXPositiveZ = SCNPlane(width: holeLength, height: holeLength)
        let holePositiveXPositiveZMaterial = SCNMaterial()
        holePositiveXPositiveZMaterial.diffuse.contents = UIColor.black
        holePositiveXPositiveZ.materials = [holePositiveXPositiveZMaterial]
        
        let holePositiveXPositiveZNode = SCNNode()
        holePositiveXPositiveZNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        holePositiveXPositiveZNode.position = SCNVector3(planeAnchor.center.x + Float(tableWidth) / 2 - Float(holeLength) / 2,
                                                         0.001,
                                                         planeAnchor.center.z + Float(tableLength) / 2 - Float(holeLength) / 2)
        holePositiveXPositiveZNode.geometry = holePositiveXPositiveZ
        node.addChildNode(holePositiveXPositiveZNode)
        
        let holeNegativeZMid = SCNPlane(width: holeLength, height: holeLength)
        let holeNegativeZMidMaterial = SCNMaterial()
        holeNegativeZMidMaterial.diffuse.contents = UIColor.black
        holeNegativeZMid.materials = [holeNegativeZMidMaterial]
        
        let holeNegativeZMidNode = SCNNode()
        holeNegativeZMidNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        holeNegativeZMidNode.position = SCNVector3(planeAnchor.center.x - Float(holeLength) / 4,
                                                   0.001,
                                                   planeAnchor.center.z - Float(tableLength) / 2 + Float(holeLength) / 2)
        holeNegativeZMidNode.geometry = holeNegativeZMid
        node.addChildNode(holeNegativeZMidNode)
        
        let holePositiveZMid = SCNPlane(width: holeLength, height: holeLength)
        let holePositiveZMidMaterial = SCNMaterial()
        holePositiveZMidMaterial.diffuse.contents = UIColor.black
        holePositiveZMid.materials = [holePositiveZMidMaterial]
        
        let holePositiveZMidNode = SCNNode()
        holePositiveZMidNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        holePositiveZMidNode.position = SCNVector3(planeAnchor.center.x - Float(holeLength) / 4,
                                                   0.001,
                                                   planeAnchor.center.z + Float(tableLength) / 2 - Float(holeLength) / 2)
        holePositiveZMidNode.geometry = holePositiveZMid
        node.addChildNode(holePositiveZMidNode)
        
        //setup walls
        let wallNegtiveZ = SCNPlane(width: tableWidth, height: CGFloat(ballRadius * 2))
        let wallNegativeZMaterial = SCNMaterial()
        wallNegativeZMaterial.diffuse.contents = UIColor.green
        wallNegtiveZ.materials = [wallNegativeZMaterial]
        
        let wallNegativeZNode = WallNode()
        wallNegativeZNode.setWidth(width: tableWidth, wallType: .negativeZ)
        wallNegativeZNode.position = SCNVector3(planeAnchor.center.x,
                                                ballRadius,
                                                planeAnchor.center.z - Float(tableLength) / 2)
        wallNegativeZNode.geometry = wallNegtiveZ
        wallNegativeZNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: wallNegtiveZ, options: nil))
        wallNegativeZNode.physicsBody?.categoryBitMask = ObjectCategory.wall.categoryBit
        wallNegativeZNode.physicsBody?.contactTestBitMask = ObjectCategory.motherBall.categoryBit | ObjectCategory.targetBall.categoryBit
        wallNegativeZNode.physicsBody?.collisionBitMask = ObjectCategory.motherBall.categoryBit | ObjectCategory.targetBall.categoryBit
        wallNegativeZNode.name = ObjectCategory.wall.nodeName
        
        node.addChildNode(wallNegativeZNode)
        
        let wallPositiveZ = SCNPlane(width: tableWidth, height: CGFloat(ballRadius * 2))
        let wallPositiveZMaterial = SCNMaterial()
        wallPositiveZMaterial.diffuse.contents = UIColor.green
        wallPositiveZ.materials = [wallNegativeZMaterial]
        
        let wallPositiveZNode = WallNode()
        wallPositiveZNode.setWidth(width: tableWidth, wallType: .positiveZ)
        wallPositiveZNode.position = SCNVector3(planeAnchor.center.x,
                                                ballRadius,
                                                planeAnchor.center.z + Float(tableLength) / 2)
        wallPositiveZNode.geometry = wallPositiveZ
        wallPositiveZNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: wallPositiveZ, options: nil))
        wallPositiveZNode.physicsBody?.categoryBitMask = ObjectCategory.wall.categoryBit
        wallPositiveZNode.physicsBody?.contactTestBitMask = ObjectCategory.motherBall.categoryBit | ObjectCategory.targetBall.categoryBit
        wallPositiveZNode.physicsBody?.collisionBitMask = ObjectCategory.motherBall.categoryBit | ObjectCategory.targetBall.categoryBit
        wallPositiveZNode.name = ObjectCategory.wall.nodeName
        
        node.addChildNode(wallPositiveZNode)
        
        let wallNegtiveX = SCNPlane(width: tableLength, height: CGFloat(ballRadius * 2))
        let wallNegativeXMaterial = SCNMaterial()
        wallNegativeXMaterial.diffuse.contents = UIColor.green
        wallNegtiveX.materials = [wallNegativeXMaterial]
        
        let wallNegativeXNode = WallNode()
        wallNegativeXNode.setWidth(width: tableLength, wallType: .negativeX)
        wallNegativeXNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 0, 1, 0)
        wallNegativeXNode.position = SCNVector3(planeAnchor.center.x - Float(tableWidth) / 2,
                                                ballRadius,
                                                planeAnchor.center.z)
        
        wallNegativeXNode.geometry = wallNegtiveX
        wallNegativeXNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: wallNegtiveX, options: nil))
        wallNegativeXNode.physicsBody?.categoryBitMask = ObjectCategory.wall.categoryBit
        wallNegativeXNode.physicsBody?.contactTestBitMask = ObjectCategory.motherBall.categoryBit | ObjectCategory.targetBall.categoryBit
        wallNegativeXNode.physicsBody?.collisionBitMask = ObjectCategory.motherBall.categoryBit | ObjectCategory.targetBall.categoryBit
        wallNegativeXNode.name = ObjectCategory.wall.nodeName
        
        node.addChildNode(wallNegativeXNode)
        
        let wallPositiveX = SCNPlane(width: tableLength, height: CGFloat(ballRadius * 2))
        let wallPositiveXMaterial = SCNMaterial()
        wallPositiveXMaterial.diffuse.contents = UIColor.green
        wallPositiveX.materials = [wallPositiveXMaterial]
        
        let wallPositiveXNode = WallNode()
        wallPositiveXNode.setWidth(width: tableLength, wallType: .positiveX)
        wallPositiveXNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 0, 1, 0)
        wallPositiveXNode.position = SCNVector3(planeAnchor.center.x + Float(tableWidth) / 2,
                                                ballRadius,
                                                planeAnchor.center.z)
        wallPositiveXNode.geometry = wallPositiveX
        wallPositiveXNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: wallPositiveX, options: nil))
        wallPositiveXNode.physicsBody?.categoryBitMask = ObjectCategory.wall.categoryBit
        wallPositiveXNode.physicsBody?.contactTestBitMask = ObjectCategory.motherBall.categoryBit | ObjectCategory.targetBall.categoryBit
        wallPositiveXNode.physicsBody?.collisionBitMask = ObjectCategory.motherBall.categoryBit | ObjectCategory.targetBall.categoryBit
        wallPositiveXNode.name = ObjectCategory.wall.nodeName
        
        node.addChildNode(wallPositiveXNode)
    }
    
    private func setupMotherBall(planeAnchor: ARPlaneAnchor, node: SCNNode) {
        let motherBall = SCNSphere(radius: CGFloat(ballRadius))
        let ballMaterial = SCNMaterial()
        ballMaterial.diffuse.contents = UIColor.white
        motherBall.materials = [ballMaterial]
        
        motherBallNode = BallNode()
        motherBallNode.position = SCNVector3(planeAnchor.center.x - Float(tableWidth) / 4, ballRadius, planeAnchor.center.z)
        motherBallNode.geometry = motherBall
        motherBallNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: motherBall, options: nil))
        motherBallNode.physicsBody?.categoryBitMask = ObjectCategory.motherBall.categoryBit
        motherBallNode.physicsBody?.contactTestBitMask = ObjectCategory.wall.categoryBit | ObjectCategory.targetBall.categoryBit
        motherBallNode.name = ObjectCategory.motherBall.nodeName
        
        node.addChildNode(motherBallNode)
    }
    
    private func setupTargetBall(planeAnchor: ARPlaneAnchor, node: SCNNode) {
        for i in 1...6 {
            let targetBall = SCNSphere(radius: CGFloat(ballRadius))
            let targetBallMaterial = SCNMaterial()
            targetBallMaterial.diffuse.contents = UIColor.red
            targetBall.materials = [targetBallMaterial]
            
            let (xOffet, zOffset) = Int.offsetFromFirst(index: i, space: ballRadius * 2.5)
            let targetBallNode = BallNode()
            targetBallNode.position = SCNVector3(planeAnchor.center.x + xOffet, ballRadius, planeAnchor.center.z + zOffset)
            targetBallNode.geometry = targetBall
            targetBallNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: targetBall, options: nil))
            targetBallNode.physicsBody?.categoryBitMask = ObjectCategory.targetBall.categoryBit
            targetBallNode.physicsBody?.contactTestBitMask = ObjectCategory.wall.categoryBit | ObjectCategory.motherBall.categoryBit |  ObjectCategory.targetBall.categoryBit
            targetBallNode.name = ObjectCategory.targetBall.nodeName + "\(i)"
            
            node.addChildNode(targetBallNode)
        }
    }
}

extension MainViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = (contact.nodeA as! ContactNode)
        let nodeB = (contact.nodeB as! ContactNode)
        if nodeA.contactList.contains(nodeB.name!) || nodeB.contactList.contains(nodeA.name!) {
            return
        }
        
        nodeA.contactList.append(nodeB.name!)
        nodeB.contactList.append(nodeA.name!)
        
        //Ball hits the wall
        if nodeA.name == ObjectCategory.wall.nodeName || nodeB.name == ObjectCategory.wall.nodeName {
            ballHitsWall(contact: contact)
            return
        }
        
        ballHitsBall(contact: contact)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        let nodeA = (contact.nodeA as! ContactNode)
        let nodeB = (contact.nodeB as! ContactNode)
        
        nodeA.contactList.removeAll(where: { $0 == nodeB.name! })
        nodeB.contactList.removeAll(where: { $0 == nodeA.name! })
    }
    
    private func ballHitsWall(contact: SCNPhysicsContact) {
        var ballNode: BallNode!
        var wallNode: WallNode!
        
        if contact.nodeA.name == ObjectCategory.motherBall.nodeName || contact.nodeA.name!.contains(ObjectCategory.targetBall.nodeName) {
            ballNode = (contact.nodeA as! BallNode)
            wallNode = (contact.nodeB as! WallNode)
        }
        
        if contact.nodeB.name == ObjectCategory.motherBall.nodeName || contact.nodeB.name!.contains(ObjectCategory.targetBall.nodeName) {
            ballNode = (contact.nodeB as! BallNode)
            wallNode = (contact.nodeA as! WallNode)
        }

        if wallNode.hitsHole(contactPoint: contact.contactPoint, wallType: wallNode.wallType) {
            ballNode.removeFromParentNode()
            
            if ballNode.name == ObjectCategory.motherBall.nodeName {
                reset()
            }
            
            if planeNode!.childNodes.filter({ $0 is BallNode }).count == 1 {
                reset()
            }
        }
        
        ballNode.removeAction(forKey: ballNode.name!)
        
        guard ballNode.ballSpeed > 0.0001 else {
            ballNode.moved(ballSpeed: 0, ballDirection: SCNVector3(1, 0, 0))
            return
        }
        
        let normal = contact.contactNormal.xzPlane.rotationByY(degree: -worldRotation)
        
        let normalComponent = ballNode.ballDirection.normalComponent(wrt: normal)
        let tangentCompoent = ballNode.ballDirection.tangentComponent(wrt: normal)
        let reflectedBallDirection = SCNVector3(tangentCompoent.x - normalComponent.x,
                                                0,
                                                tangentCompoent.z - normalComponent.z).normalized
        
        ballNode.moved(ballSpeed: ballNode.ballSpeed/2, ballDirection: reflectedBallDirection)
        ballNode.runAction(SCNAction.moveBy(x: CGFloat(reflectedBallDirection.x * ballNode.ballSpeed * 3),
                                            y: 0,
                                            z: CGFloat(reflectedBallDirection.z * ballNode.ballSpeed * 3),
                                            duration: 3), forKey: ballNode.name!)
}
    
    private func ballHitsBall(contact: SCNPhysicsContact) {
        let ballNodeA = (contact.nodeA as! BallNode)
        let ballNodeB = (contact.nodeB as! BallNode)
        
        if ballNodeA.actionKeys.isEmpty {
            ballNodeA.ballSpeed = 0
        }
        if ballNodeB.actionKeys.isEmpty {
            ballNodeB.ballSpeed = 0
        }
        
        if ballNodeA.actionKeys.contains(ballNodeA.name!) {
            ballNodeA.removeAction(forKey: ballNodeA.name!)
        }
        if ballNodeB.actionKeys.contains(ballNodeB.name!) {
            ballNodeB.removeAction(forKey: ballNodeB.name!)
        }
        
        let normal = contact.contactNormal.xzPlane.rotationByY(degree: -worldRotation)
        
        if ballNodeA.ballSpeed == 0 {
            ballNodeA.ballDirection = normal.dot(vector: ballNodeB.ballDirection) > 0 ? normal : normal.negative
        }
        if ballNodeB.ballSpeed == 0 {
            ballNodeB.ballDirection = normal.dot(vector: ballNodeA.ballDirection) > 0 ? normal : normal.negative
        }
        
        let normalComponentA = ballNodeA.ballDirection.normalComponent(wrt: normal)
        let tangentCompoentA = ballNodeA.ballDirection.tangentComponent(wrt: normal)
        let normalComponentB = ballNodeB.ballDirection.normalComponent(wrt: normal)
        let tangentCompoentB = ballNodeB.ballDirection.tangentComponent(wrt: normal)
        
        let aHitsB = (ballNodeA.ballSpeed * normalComponentA.length).power(exponential: 2) > (ballNodeB.ballSpeed * normalComponentB.length).power(exponential: 2)
        let coefficientA: Float = aHitsB ? 0.0 : 0.5
        let coefficientB: Float = aHitsB ? 0.5 : 0.0
        
        let normalComponentAAfter = SCNVector3((normalComponentA.x * ballNodeA.ballSpeed + normalComponentB.x * ballNodeB.ballSpeed) * coefficientA,
                                              0,
                                              (normalComponentA.z * ballNodeA.ballSpeed + normalComponentB.z * ballNodeB.ballSpeed) * coefficientA)
        
        let reflectedBallAVelocity = SCNVector3(tangentCompoentA.x * ballNodeA.ballSpeed + normalComponentAAfter.x,
                                                0,
                                                tangentCompoentA.z * ballNodeA.ballSpeed + normalComponentAAfter.z)

        let normalComponentBAfter = SCNVector3((normalComponentA.x * ballNodeA.ballSpeed + normalComponentB.x * ballNodeB.ballSpeed) * coefficientB,
                                                0,
                                               (normalComponentA.z * ballNodeA.ballSpeed + normalComponentB.z * ballNodeB.ballSpeed) * coefficientB)
          
        let reflectedBallBVelocity = SCNVector3(tangentCompoentB.x * ballNodeB.ballSpeed + normalComponentBAfter.x,
                                                0,
                                                tangentCompoentB.z * ballNodeB.ballSpeed + normalComponentBAfter.z)
        
        if reflectedBallAVelocity.length > 0.0001 {
            ballNodeA.moved(ballSpeed: reflectedBallAVelocity.length, ballDirection: reflectedBallAVelocity.normalized)
            ballNodeA.runAction(SCNAction.moveBy(x: CGFloat(reflectedBallAVelocity.x * 3),
                                                 y: 0,
                                                 z: CGFloat(reflectedBallAVelocity.z * 3),
                                                 duration: 3), forKey: ballNodeA.name!)
        } else {
            ballNodeA.moved(ballSpeed: 0, ballDirection: SCNVector3(1, 0, 0))
        }
        
        if reflectedBallBVelocity.length > 0.0001 {
            ballNodeB.moved(ballSpeed: reflectedBallBVelocity.length, ballDirection: reflectedBallBVelocity.normalized)
            ballNodeB.runAction(SCNAction.moveBy(x: CGFloat(reflectedBallBVelocity.x * 3),
                                                 y: 0,
                                                 z: CGFloat(reflectedBallBVelocity.z * 3),
                                                 duration: 3), forKey: ballNodeB.name!)
        } else {
            ballNodeB.moved(ballSpeed: 0, ballDirection: SCNVector3(1, 0, 0))
        }
        
    }

}
