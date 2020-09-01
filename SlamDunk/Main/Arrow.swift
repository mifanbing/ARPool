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
}
