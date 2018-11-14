import Swift
import RxSwift

protocol AuthRepository {
    func hasPersonCredentials() -> Bool
    func getPersonInvitation() -> Observable<Result<AuthToken>>
    func askLoginEmail(_ email: String) -> Observable<Result<Bool>>
    func login(_ token: String) -> Observable<Result<AuthToken>>
    func register(_ email: String, _ username: String) -> Observable<Result<Bool>>
    func isRegisterCompleted() -> Bool
    func confirmEmail(_ confirmationToken: String) -> Observable<Result<Bool>>
    func minVersion() -> Observable<Result<Int>>
    func blockPerson(_ username: String) -> Observable<Result<Bool>>
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
                    self.storageRepo.setIsRegisterCompleted(true)
                case .error: break
                case .inProgress: break
                }
            })
    }

    func register(_ email: String, _ username: String) -> Observable<Result<Bool>> {
        return apiRepo.register(email, username)
    }

    func isRegisterCompleted() -> Bool {
        return storageRepo.isRegisterCompleted()
    }

    func confirmEmail(_ confirmationToken: String) -> Observable<Result<Bool>> {
        return apiRepo.confirmEmail(confirmationToken)
            .do(onNext: { result in
                switch result.status {
                case .success:
                    self.storageRepo.setIsRegisterCompleted(true)
                case .error: break
                case .inProgress: break
                }
            })
    }

    func minVersion() -> Observable<Result<Int>> {
        return apiRepo.minVersion()
    }

    func blockPerson(_ username: String) -> Observable<Result<Bool>> {
        return apiRepo.blockPerson(username)
    }
}
