import Swift
import RxSwift
import Moya
import Moya_ObjectMapper

extension Single where Element == Response {
    
    private func getObservableSubscribed(_ scheduler: ImmediateSchedulerType)
                                                                           -> Observable<Response> {
        return self.asObservable()
                .subscribeOn(scheduler)
    }
    
    func transformNetworkResponse<T: ToResultMapper>(_ mapperType: T.Type,
                                                     _ scheduler: ImmediateSchedulerType)
                                                               -> Observable<Result<T.domainType>> {
        return getObservableSubscribed(scheduler)
                .mapObject(mapperType)
                .map { filledMapper in return filledMapper.toResult() }
                .retryCatchErrorAndEmitInProgress(T.domainType.self)
    }
    
    func transformNetworkListResponse<T: ToDomainMapper>(_ mapperType: T.Type,
                                                         _ scheduler: ImmediateSchedulerType)
                                                             -> Observable<Result<[T.domainType]>> {
        return (getObservableSubscribed(scheduler)
                .mapArray(mapperType)
                .map { filledMappers in
                    var domains = [T.domainType]()
                    for mapper in filledMappers {
                        domains.append(mapper.toDomain())
                    }
                    return Result(.success, data: domains)
                } as Observable<Result<[T.domainType]>>)
            .retryCatchErrorAndEmitInProgress([T.domainType].self)
    }
}

extension Observable {
    
    func retryCatchErrorAndEmitInProgress<U: Equatable>(_ type: U.Type) -> Observable<Result<U>> {
            return (self as! Observable<Result<U>>).retry(2)
                .catchError { moyaError in
                    switch (moyaError as! MoyaError) {
                    case .underlying(let error, _):
                        if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                            return Observable<Result<U>>.just(
                                Result<U>(error: DataError.noInternetConnection))
                        }
                    default:
                        throw moyaError
                    }
                    throw moyaError
                }
                .startWith(Result<U>(.inProgress))
    }
}
