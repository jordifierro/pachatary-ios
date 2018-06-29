import Swift
import RxSwift

protocol SceneRepository {
    func scenesObservable(experienceId: String) -> Observable<Result<[Scene]>>
}

class SceneRepoImplementation<R: ResultCache>: SceneRepository where R.cacheType == Scene {
    
    let apiRepo: SceneApiRepository!
    let generateNewCache: (() -> R)!
    var cacheStore = [String : R]()
    
    init(apiRepo: SceneApiRepository, generateNewCache: @escaping (() -> R)) {
        self.apiRepo = apiRepo
        self.generateNewCache = generateNewCache
    }
    
    func scenesObservable(experienceId: String) -> Observable<Result<[Scene]>> {
        if cacheStore[experienceId] == nil {
            cacheStore[experienceId] = generateNewCache()
            getScenes(experienceId: experienceId)
            return cacheStore[experienceId]!.resultObservable
        }
        return cacheStore[experienceId]!.resultObservable
            .flatMapFirst { (result) -> Observable<Result<[Scene]>> in
                if result.isError() {
                    self.getScenes(experienceId: experienceId)
                    return Observable<Result<[Scene]>>.empty()
                }
                else { return Observable.just(result) }
            }
    }
    
    private func getScenes(experienceId: String) {
        _ = apiRepo.scenesObservable(experienceId: experienceId)
            .subscribe { event in
                switch event {
                case .next(let result):
                    self.cacheStore[experienceId]?.replaceResultObserver.onNext(result)
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed: break
                }
        }
    }
}




