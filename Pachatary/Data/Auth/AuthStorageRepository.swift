import Foundation
import SwiftKeychainWrapper

protocol AuthStorageRepository {
    func getPersonCredentials() throws -> AuthToken
    func setPersonCredentials(authToken: AuthToken)
    func setIsRegisterCompleted(_ isCompleted: Bool)
    func isRegisterCompleted() -> Bool
}

class AuthStorageRepoImplementation: AuthStorageRepository {

    let ACCESS_TOKEN_KEY = "auth_access_token"
    let REFRESH_TOKEN_KEY = "auth_refresh_token"
    let IS_REGISTER_COMPLETED = "auth_is_register_completed"
    
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

    func isRegisterCompleted() -> Bool {
        let isRegisterCompleted = KeychainWrapper.standard.bool(forKey: IS_REGISTER_COMPLETED)
        if isRegisterCompleted == nil { return false }
        return isRegisterCompleted!
    }

    func setIsRegisterCompleted(_ isCompleted: Bool) {
        KeychainWrapper.standard.set(isCompleted, forKey: IS_REGISTER_COMPLETED)
    }
    
    func removeAll() {
        KeychainWrapper.standard.removeObject(forKey: ACCESS_TOKEN_KEY)
        KeychainWrapper.standard.removeObject(forKey: REFRESH_TOKEN_KEY)
        KeychainWrapper.standard.removeObject(forKey: IS_REGISTER_COMPLETED)
    }
}
