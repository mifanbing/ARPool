import SceneKit

class BallNode: SCNNode {
    var ballSpeed: Float = 0
    var ballDirection = SCNVector3(1, 0, 0)
    
    func moved(ballSpeed: Float, ballDirection: SCNVector3) {
        self.ballSpeed = ballSpeed
        self.ballDirection = ballDirection
    }
}
