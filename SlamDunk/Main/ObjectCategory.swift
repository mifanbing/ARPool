enum ObjectCategory {
    case motherBall
    case targetBall
    case wall
    
    var categoryBit: Int {
        switch self {
        case .motherBall:
            return 1
        case .targetBall:
            return 2
        case .wall:
            return 4
        }
    }
    
    var nodeName: String {
        switch self {
        case .motherBall:
            return "mother"
        case .targetBall:
            return "target"
        case .wall:
            return "wall"
        }
    }
}
