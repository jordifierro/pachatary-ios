import Swift
import RxSwift

protocol Requester {
    associatedtype requesterType: Identifiable & Equatable
    
    var getFirstsCallable: ((Request) -> Observable<Result<[requesterType]>>)! { get set }
    var actionsObserver: AnyObserver<Request> { get }
    func resultsObservable() -> Observable<Result<[requesterType]>>
}

class RequesterImplementation<T: ResultCache>: Requester {

    var getFirstsCallable: ((Request) -> Observable<Result<[T.cacheType]>>)!
    let cache: T!
    var actionsObserver: AnyObserver<Request>

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
                    case .paginate: break
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

