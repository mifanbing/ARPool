import SceneKit

extension SCNShape {
    static func arrow() -> SCNShape {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 2))
        path.addLine(to: CGPoint(x: -1, y: 2))
        path.addLine(to: CGPoint(x: 1, y: 3))
        path.addLine(to: CGPoint(x: 3, y: 2))
        path.addLine(to: CGPoint(x: 2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        
        path.close()
        
        return SCNShape(path: path, extrusionDepth: 0)
    }
}
