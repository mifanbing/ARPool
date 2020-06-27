import SceneKit

class WallNode: ContactNode {
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
        
        switch wallType {
        case .negativeX, .positiveX:
            if ratio < 0.06 || ratio > 0.94 { return true }
        case .negativeZ, .positiveZ:
            if ratio < 0.1 || ratio > 0.9 { return true }
        }
        
        
        if [WallType.negativeZ, WallType.positiveZ].contains(wallType) {
            return (ratio > 0.47 && ratio < 0.53)
        }
        
        return false
    }
}
