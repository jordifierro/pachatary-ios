import Swift
import RxSwift

protocol Requester {
    associatedtype requesterType: Identifiable & Equatable
    
    var getFirstsCallable: ((Request) -> Observable<Result<[requesterType]>>)! { get set }
    var paginateCallable: ((String) -> Observable<Result<[requesterType]>>)! { get set }
    var actionsObserver: AnyObserver<Request> { get }
    func resultsObservable() -> Observable<Result<[requesterType]>>
    var updateObserver: AnyObserver<[requesterType]> { get }
}

class RequesterImplementation<T: ResultCache>: Requester {

    var getFirstsCallable: ((Request) -> Observable<Result<[T.cacheType]>>)!
    var paginateCallable: ((String) -> Observable<Result<[T.cacheType]>>)!
    var actionsObserver: AnyObserver<Request>
    
    let cache: T!
    var updateObserver: AnyObserver<[T.cacheType]> { get { return cache.updateObserver } }

    init(_ cache: T) {
        self.cache = cache
        let actionsSubject = PublishSubject<Request>()
        self.actionsObserver = actionsSubject.asObserver()
        
        _ = actionsSubject.asObservable()
            .withLatestFrom(cache.resultObservable) { request, result in (request, result) }
            .subscribe { event in
                switch event {
                case .next(let (request, result)):
                    switch request.action! {
                    case .getFirsts:
                        if !(result.isInProgress()) &&
                            (!result.hasBeenInitialized() || result.isError()) {
                            _ = self.getFirstsCallable(request)
                                .subscribe { event in
                                    switch event {
                                    case .next(let result):
                                        self.cache.replaceResultObserver.onNext(
                                            result.builder().action(.getFirsts).build())
                                    case .error: break
                                    case .completed: break
                                    }
                                }
                            }
                    case .paginate:
                        if !(result.isInProgress()) && (
                                (result.isSuccess() && result.hasBeenInitialized()) ||
                                (result.isError() && result.action == .paginate)
                            ) && result.hasMoreElements() {
                            _ = self.paginateCallable(result.nextUrl!).subscribe { event in
                                switch event {
                                case .next(let apiResult):
                                    if !apiResult.isSuccess() {
                                        cache.replaceResultObserver.onNext(
                                            result.builder()
                                                .action(.paginate)
                                                .status(apiResult.status)
                                                .error(apiResult.error)
                                            .build()
                                        )
                                    }
                                    else {
                                        cache.replaceResultObserver.onNext(
                                            apiResult.builder()
                                                .data(result.data! + apiResult.data!)
                                                .action(.paginate)
                                            .build()
                                        )
                                    }
                                case .error(let error):
                                    fatalError(error.localizedDescription)
                                case .completed: break
                                }
                            }
                        }
                    case .refresh: break
                    case .none: break
                    }
                case .error: break
                case .completed: break
                }
            }
    }
    
    func resultsObservable() -> Observable<Result<[T.cacheType]>> {
        return cache.resultObservable
    }
}

