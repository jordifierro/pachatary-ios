import Swift

struct AuthToken: Equatable {
    
    let accessToken: String!
    let refreshToken: String!
    
    init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    static func == (lhs: AuthToken, rhs: AuthToken) -> Bool {
        return lhs.accessToken == rhs.accessToken && lhs.refreshToken == rhs.refreshToken
    }
}

