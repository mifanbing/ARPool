import SceneKit

extension Float {
    func power(exponential: Int) -> Float {
        var answer: Float = 1.0
        for _ in 0..<exponential {
            answer = answer * self
        }
        return answer
    }
}

extension SCNVector3 {
    var length: Float {
        return sqrt(x.power(exponential: 2) + y.power(exponential: 2) + z.power(exponential: 2))
    }
    
    var normalized: SCNVector3 {
        return SCNVector3(x / length, y / length, z / length)
    }
    
    var negative: SCNVector3 {
        return SCNVector3(-x, -y, -z)
    }
    
    var xzPlane: SCNVector3 {
        return SCNVector3(x, 0, z).normalized
    }
    
    func dot(vector: SCNVector3) -> Float {
        return self.x * vector.x + self.y * vector.y + self.z * vector.z
    }
    
    func normalComponent(wrt vector: SCNVector3) -> SCNVector3 {
        let vector = vector.normalized
        let length = self.dot(vector: vector)
        
        return SCNVector3(x: vector.x * length, y: vector.y * length, z: vector.z * length)
    }
    
    func tangentComponent(wrt vector: SCNVector3) -> SCNVector3 {
        let vector = vector.normalized
        let normal = normalComponent(wrt: vector)
        
        return SCNVector3(x: vector.x - normal.x, y: vector.y - normal.y, z: vector.z - normal.z)
    }
}
