import Swift

class Request: Equatable {
    
    enum Action {
        case none
        case getFirsts
        case paginate
        case refresh
    }
    
    let action: Action!
    
    init(_ action: Action) {
        self.action = action
    }
    
    public static func == (lhs: Request, rhs: Request) -> Bool {
        return lhs.action == rhs.action
    }
}

