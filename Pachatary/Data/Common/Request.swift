import Swift

class Request: Equatable {
    
    enum Action {
        case none
        case getFirsts
        case paginate
        case refresh
    }

    class Params: Equatable {

        let word: String?
        let latitude: Double?
        let longitude: Double?

        init(_ word: String? = nil, _ latitude: Double? = nil, _ longitude: Double? = nil) {
            self.word = word
            self.latitude = latitude
            self.longitude = longitude
        }

        public static func == (lhs: Params, rhs: Params) -> Bool {
            return lhs.word == rhs.word
                && lhs.latitude == rhs.latitude
                && lhs.longitude == rhs.longitude
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

