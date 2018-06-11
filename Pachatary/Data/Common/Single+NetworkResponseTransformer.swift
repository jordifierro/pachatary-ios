import Swift
import RxSwift
import Moya
import Moya_ObjectMapper

extension Single where Element == Response {
    
    func transformNetworkResponse<T: ToDomainMapper>(_ mapperType: T.Type,
                                                     _ scheduler: ImmediateSchedulerType)
                                                               -> Observable<Result<T.domainType>> {
        return self.asObservable()
            .subscribeOn(scheduler)
            .mapObject(mapperType)
            .map { filledMapper in return Result(.success, data: filledMapper.toDomain()) }
            .retry(2)
            .catchError { moyaError in
                switch (moyaError as! MoyaError) {
                case .underlying(let error, _):
                    if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                        return Observable.just(
                            Result<T.domainType>(.error, error: DataError.noInternetConnection))
                    }
                default:
                    throw moyaError
                }
                throw moyaError
            }
            .startWith(Result<T.domainType>(.inProgress))
    }
}

