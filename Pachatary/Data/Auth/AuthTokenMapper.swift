import ObjectMapper

struct AuthTokenMapper: ToDomainMapper {
    
    typealias domainType = AuthToken
    
    var authToken: AuthToken!
    var accessToken: String!
    var refreshToken: String!

    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        accessToken <- map["access_token"]
        refreshToken <- map["refresh_token"]
        authToken = AuthToken(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    func toDomain() -> AuthToken {
        return authToken
    }
}



