import SceneKit

extension SCNShape {
    static func arrow() -> SCNShape {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: -0.01))
        path.addLine(to: CGPoint(x: 0.029, y: -0.01))
        path.addLine(to: CGPoint(x: 0.03, y: -0.02))
        path.addLine(to: CGPoint(x: 0.04, y: 0))
        path.addLine(to: CGPoint(x: 0.03, y: 0.02))
        path.addLine(to: CGPoint(x: 0.029, y: 0.01))
        path.addLine(to: CGPoint(x: 0, y: 0.01))
        path.addLine(to: CGPoint(x: 0, y: -0.01))
        
        path.close()
        
        return SCNShape(path: path, extrusionDepth: 0)
    }
    
    static func quadCircle(radius: Double) -> SCNShape {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        //path.addLine(to: CGPoint(x: 0.05, y: 0))
        let n = 20
        (0...n).forEach {
            let angle = Double.pi / 2 * Double($0) / Double(n)
            path.addLine(to: CGPoint(x: radius * cos(angle), y: radius * sin(angle)))
        }
        path.addLine(to: CGPoint(x: 0, y: 0))
        
        path.close()
        
        return SCNShape(path: path, extrusionDepth: 0)
    }
}
