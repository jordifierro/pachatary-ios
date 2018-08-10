import Swift
import RxSwift

protocol AuthRepository {
    func hasPersonCredentials() -> Bool
    func getPersonInvitation() -> Observable<Result<AuthToken>>
    func askLoginEmail(_ email: String) -> Observable<Result<Bool>>
    func login(_ token: String) -> Observable<Result<AuthToken>>
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
    
    func getPersonInvitation() -> Observable<Result<AuthToken>> {
        return apiRepo.getPersonInvitation()
            .do(onNext: { result in
                switch result.status {
                case .success:
                    self.storageRepo.setPersonCredentials(authToken: result.data!)
                case .error: break
                case .inProgress: break
                }
            })
    }
    
    func askLoginEmail(_ email: String) -> Observable<Result<Bool>> {
        return apiRepo.askLoginEmail(email)
    }
    
    func login(_ token: String) -> Observable<Result<AuthToken>> {
        return apiRepo.login(token)
            .do(onNext: { result in
                switch result.status {
                case .success:
                    self.storageRepo.setPersonCredentials(authToken: result.data!)
                case .error: break
                case .inProgress: break
                }
            })
    }
}
