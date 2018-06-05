import Swift
import RxSwift
import Moya

protocol AuthApiRepository {
    func getPersonInvitation() -> Observable<AuthToken>
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

    func getPersonInvitation() -> Observable<AuthToken> {
        return self.api.request(.createPerson(clientSecretKey: self.clientSecretKey))
            .subscribeOn(ioScheduler)
            .mapObject(AuthTokenMapper.self)
            .map { mapper in return mapper.toDomain() }
            .asObservable()
    }
}

