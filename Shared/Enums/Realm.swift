// MARK - Entities
@objc enum Options: Int, CaseIterable, CustomStringConvertible {
    case keep
    case setTrue
    case setFalse
    
    var description: String {
        switch self {
            case .setTrue:  return "true"
            case .setFalse: return "false"
            default:        return "keep"
        }
    }
}

@objc enum Color: Int, CustomStringConvertible {
    case keep
    case blue
    case purple
    case pink
    case red
    case orange
    case yellow
    case green
    case graphite
    
    var description: String {
            switch self {
            case .blue:     return "Blue"
            case .purple:   return "Purple"
            case .pink:     return "Pink"
            case .red:      return "Red"
            case .orange:   return "Orange"
            case .yellow:   return "Yellow"
            case .green:    return "Green"
            case .graphite: return "Graphite"
            default:        return "keep"
        }
    }
}
