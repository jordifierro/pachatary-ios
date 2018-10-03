import Swift
import RxSwift

protocol Requester {
    associatedtype requesterType: Identifiable & Equatable
    
    func request(_ request: Request)
    func resultsObservable() -> Observable<Result<[requesterType]>>
    func update(_ tList: [requesterType])
    func addOrUpdate(_ tList: [requesterType])
}

class RequesterImplementation<T: ResultCache>: Requester {

    let cache: T!
    let getFirstsCallable: ((Request.Params?) -> Observable<Result<[T.cacheType]>>)
    let paginateCallable: ((String) -> Observable<Result<[T.cacheType]>>)
    private var actionsObserver: AnyObserver<Request>

    init(_ cache: T,
         _ getFirstsCallable: @escaping ((Request.Params?) -> Observable<Result<[T.cacheType]>>),
         _ paginateCallable: @escaping ((String) -> Observable<Result<[requesterType]>>)) {
        self.cache = cache
        self.getFirstsCallable = getFirstsCallable
        self.paginateCallable = paginateCallable
        let actionsSubject = PublishSubject<Request>()
        self.actionsObserver = actionsSubject.asObserver()
        
        _ = actionsSubject.asObservable()
            .withLatestFrom(cache.resultObservable) { request, result in (request, result) }
            .subscribe { event in
                switch event {
                case .next(let (request, result)):
                    switch request.action! {
                    case .getFirsts:
                        if !result.isInProgress() || (request.params != result.params) {
                            _ = self.getFirstsCallable(request.params)
                                .subscribe { event in
                                    switch event {
                                    case .next(let result):
                                        self.cache.replaceResult(
                                            result.builder()
                                                    .data(result.data ?? [])
                                                    .action(.getFirsts)
                                                    .params(request.params)
                                                    .build())
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
                                        cache.replaceResult(
                                            result.builder()
                                                .action(.paginate)
                                                .status(apiResult.status)
                                                .error(apiResult.error)
                                            .build()
                                        )
                                    }
                                    else {
                                        cache.replaceResult(
                                            apiResult.builder()
                                                .data(result.data! + apiResult.data!)
                                                .params(request.params)
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
    
    func request(_ request: Request) {
        actionsObserver.onNext(request)
    }

    func update(_ tList: [T.cacheType]) {
        self.cache.update(tList)
    }

    func addOrUpdate(_ tList: [T.cacheType]) {
        self.cache.addOrUpdate(tList)
    }

    func resultsObservable() -> Observable<Result<[T.cacheType]>> {
        return cache.resultObservable
    }
}

