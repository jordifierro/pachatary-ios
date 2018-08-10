import Foundation
import SwiftKeychainWrapper

protocol AuthStorageRepository {
    func getPersonCredentials() throws -> AuthToken
    func setPersonCredentials(authToken: AuthToken)
}

class AuthStorageRepoImplementation: AuthStorageRepository {

    let ACCESS_TOKEN_KEY = "auth_access_token"
    let REFRESH_TOKEN_KEY = "auth_refresh_token"
    
    func getPersonCredentials() throws -> AuthToken {
        let accessToken = KeychainWrapper.standard.string(forKey: ACCESS_TOKEN_KEY)
        let refreshToken = KeychainWrapper.standard.string(forKey: REFRESH_TOKEN_KEY)
        if accessToken == nil || refreshToken == nil { throw DataError.noLoggedPerson }
        return AuthToken(accessToken: accessToken!, refreshToken: refreshToken!)
    }
    
    func setPersonCredentials(authToken: AuthToken) {
        KeychainWrapper.standard.set(authToken.accessToken, forKey: ACCESS_TOKEN_KEY)
        KeychainWrapper.standard.set(authToken.refreshToken, forKey: REFRESH_TOKEN_KEY)
    }
    
    func removeAll() {
        KeychainWrapper.standard.removeObject(forKey: ACCESS_TOKEN_KEY)
        KeychainWrapper.standard.removeObject(forKey: REFRESH_TOKEN_KEY)
    }
}
