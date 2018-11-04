import Swift
import RxSwift
import Moya

protocol AuthApiRepository {
    func getPersonInvitation() -> Observable<Result<AuthToken>>
    func askLoginEmail(_ email: String) -> Observable<Result<Bool>>
    func login(_ token: String) -> Observable<Result<AuthToken>>
    func register(_ email: String, _ username: String) -> Observable<Result<Bool>>
    func confirmEmail(_ confirmationToken: String) -> Observable<Result<Bool>>
}

class AuthApiRepoImplementation: AuthApiRepository {
    
    let api: Reactive<MoyaProvider<AuthApi>>!
    let clientSecretKey: String!
    let ioScheduler: ImmediateSchedulerType!
    
    init(_ api: Reactive<MoyaProvider<AuthApi>>, _ clientSecretKey: String,
         _ ioScheduler: ImmediateSchedulerType) {
        self.api = api
        self.clientSecretKey = clientSecretKey
        self.ioScheduler = ioScheduler
    }

    func getPersonInvitation() -> Observable<Result<AuthToken>> {
        return self.api.request(.createPerson(clientSecretKey: self.clientSecretKey))
            .transformNetworkResponse(SingleResultMapper<AuthTokenMapper>.self, ioScheduler)
    }
    
    func askLoginEmail(_ email: String) -> Observable<Result<Bool>> {
        return self.api.request(.askLoginEmail(email: email))
            .transformNetworkVoidResponse(ioScheduler)
    }
    
    func login(_ token: String) -> Observable<Result<AuthToken>> {
        return self.api.request(.login(token: token))
            .transformNetworkResponse(SingleResultMapper<AuthTokenMapper>.self, ioScheduler)
    }

    func register(_ email: String, _ username: String) -> Observable<Result<Bool>> {
        return self.api.request(.register(email: email, username: username))
            .transformNetworkVoidResponseOrError(ioScheduler)
    }

    func confirmEmail(_ confirmationToken: String) -> Observable<Result<Bool>> {
        return self.api.request(.confirmEmail(confirmationToken: confirmationToken))
            .transformNetworkVoidResponseOrError(ioScheduler)
    }
}
