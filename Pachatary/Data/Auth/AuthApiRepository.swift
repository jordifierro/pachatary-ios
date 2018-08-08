import Swift
import RxSwift
import Moya

protocol AuthApiRepository {
    func getPersonInvitation() -> Observable<Result<AuthToken>>
    func askLoginEmail(_ email: String) -> Observable<Result<Bool>>
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
}

