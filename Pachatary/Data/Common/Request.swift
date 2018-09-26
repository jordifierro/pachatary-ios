import Swift

class Request: Equatable {
    
    enum Action {
        case none
        case getFirsts
        case paginate
        case refresh
    }

    class Params: Equatable {

        let word: String!

        init(_ word: String) {
            self.word = word
        }

        public static func == (lhs: Params, rhs: Params) -> Bool {
            return lhs.word == rhs.word
        }
    }

    let action: Action!
    let params: Params?

    init(_ action: Action, _ params: Params? = nil) {
        self.action = action
        self.params = params
    }
    
    public static func == (lhs: Request, rhs: Request) -> Bool {
        return lhs.action == rhs.action && lhs.params == rhs.params
    }
}

