import Swift
import RxSwift

protocol AuthRepository {
    func hasPersonCredentials() -> Bool
    func getPersonInvitation() -> Observable<AuthToken>
}

class AuthRepoImplementation: AuthRepository {
    
    let storageRepo: AuthStorageRepository!
    let apiRepo: AuthApiRepository!
    
    init(_ authStorageRepo: AuthStorageRepository, _ authApiRepo: AuthApiRepository) {
        self.storageRepo = authStorageRepo
        self.apiRepo = authApiRepo
    }
    
    func hasPersonCredentials() -> Bool {
        do {
            let _ = try storageRepo.getPersonCredentials()
            return true
        } catch {
            return false
        }
    }
    
    func getPersonInvitation() -> Observable<AuthToken> {
        return apiRepo.getPersonInvitation()
            .do(onNext: { self.storageRepo.setPersonCredentials(authToken: $0)})
    }
}

