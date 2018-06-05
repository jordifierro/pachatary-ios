import Foundation

protocol AuthStorageRepository {
    func getPersonCredentials() throws -> AuthToken
    func setPersonCredentials(authToken: AuthToken)
}

class AuthStorageRepoImplementation: AuthStorageRepository {

    let ACCESS_TOKEN_KEY = "auth_access_token"
    let REFRESH_TOKEN_KEY = "auth_refesh_token"
    
    let defaults = UserDefaults.standard
    
    func getPersonCredentials() throws -> AuthToken {
        let accessToken = defaults.string(forKey: ACCESS_TOKEN_KEY)
        let refreshToken = defaults.string(forKey: REFRESH_TOKEN_KEY)
        if accessToken == nil { throw DataError.noLoggedPerson }
        return AuthToken(accessToken: accessToken!, refreshToken: refreshToken!)
    }
    
    func setPersonCredentials(authToken: AuthToken) {
        defaults.set(authToken.accessToken, forKey: ACCESS_TOKEN_KEY)
        defaults.set(authToken.refreshToken, forKey: REFRESH_TOKEN_KEY)
    }
}

