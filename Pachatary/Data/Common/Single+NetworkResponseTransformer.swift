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
    
    func transformNetworkVoidResponse(_ scheduler: ImmediateSchedulerType) -> Observable<Result<Bool>> {
        return getObservableSubscribed(scheduler)
            .map { (response: Response) -> Result<Bool> in
                if response.statusCode >= 200 && response.statusCode < 300 {
                    return Result(.success, data: true)
                }
                else { fatalError() }
            }
            .retryCatchErrorAndEmitInProgress(Bool.self)
    }

    func transformNetworkVoidResponseOrError(_ scheduler: ImmediateSchedulerType) -> Observable<Result<Bool>> {
        return getObservableSubscribed(scheduler)
            .map { (response: Response) -> Result<Bool> in
                if response.statusCode >= 200 && response.statusCode < 300 {
                    return Result(.success, data: true)
                }
                else if response.statusCode >= 400 && response.statusCode < 500 {
                    let body = String(data: response.data, encoding: String.Encoding.utf8)
                    let json = body?.toJSON() as! [String:[String:String]]
                    let error = json["error"]!
                    let source = error["source"]!
                    let code = error["code"]!
                    let message = error["message"]!
                    return Result(.error, error:
                        DataError.clientException(source: source, code: code, message: message))
                }
                else { throw DataError.serverError }
            }
            .retryCatchErrorAndEmitInProgress(Bool.self)
    }

    
    func transformNetworkResponse<T: ToResultMapper>(_ mapperType: T.Type,
                                                     _ scheduler: ImmediateSchedulerType)
                                                               -> Observable<Result<T.domainType>> {
        return getObservableSubscribed(scheduler)
                .mapObject(mapperType)
                .map { filledMapper in return filledMapper.toResult() }
                .retryCatchErrorAndEmitInProgress(T.domainType.self)
    }

    func transformNetworkResponseOrError<T: ToResultMapper>(_ mapperType: T.Type,
                                                            _ scheduler: ImmediateSchedulerType)
        -> Observable<Result<T.domainType>> {
            return getObservableSubscribed(scheduler)
                .flatMap { response -> Observable<Result<T.domainType>> in
                    if response.statusCode >= 400 && response.statusCode < 500 {
                        let body = String(data: response.data, encoding: String.Encoding.utf8)
                        let json = body?.toJSON() as! [String:[String:String]]
                        let error = json["error"]!
                        let source = error["source"]!
                        let code = error["code"]!
                        let message = error["message"]!
                        return Observable.just(Result<T.domainType>(.error, error:
                            DataError.clientException(source: source, code: code, message: message)))
                    }
                    else {
                        return Observable.just(response)
                            .mapObject(mapperType)
                            .map { filledMapper in return filledMapper.toResult() }
                    }
                }
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
                                Result<U>(.error, error: DataError.noInternetConnection))
                        }
                    default:
                        throw moyaError
                    }
                    throw moyaError
                }
                .startWith(Result<U>(.inProgress))
    }
}

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}
