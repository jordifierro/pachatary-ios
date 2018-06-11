import Swift
import RxSwift
import Moya

protocol AuthApiRepository {
    func getPersonInvitation() -> Observable<Result<AuthToken>>
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
            .transformNetworkResponse(AuthTokenMapper.self, ioScheduler)
    }
}

