import SceneKit

class WallNode: SCNNode {
    var width: CGFloat = 0
    var wallType: WallType = .negativeX
    
    func setWidth(width: CGFloat, wallType: WallType) {
        self.width = width
        self.wallType = wallType
    }
    
    func hitsHole(contactPoint: SCNVector3, wallType: WallType) -> Bool {
        let contactPointWorldX1 = worldTransform.m11 * Float(width/2) + worldTransform.m41
        let contactPointWorldX2 = worldTransform.m11 * Float(-width/2) + worldTransform.m41
        let minX = min(contactPointWorldX1, contactPointWorldX2)
        let maxX = max(contactPointWorldX1, contactPointWorldX2)
        
        let ratio = (contactPoint.x - minX) / (maxX - minX)
        
        if ratio < 0.05 || ratio > 0.95 { return true }
        
        if [WallType.negativeZ, WallType.positiveZ].contains(wallType) {
            return (ratio > 0.45 && ratio < 0.55)
        }
        
        return false
    }
}
