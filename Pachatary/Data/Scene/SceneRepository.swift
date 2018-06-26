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
        return cacheStore[experienceId]!.resultObservable
    }
}




