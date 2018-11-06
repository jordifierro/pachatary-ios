import Swift
import RxSwift

protocol SceneRepository {
    func scenesObservable(experienceId: String) -> Observable<Result<[Scene]>>
    func refreshScenes(experienceId: String)
    func createScene(_ experienceId: String, _ title: String, _ description: String,
                     _ latitude: Double, _ longitude: Double) -> Observable<Result<Scene>>
    func uploadPicture(_ sceneId: String, _ image: UIImage)
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
        return Observable.zip(cacheStore[experienceId]!.resultObservable,
                              Observable.range(start: 0, count: 1000),
                              resultSelector:
            { (result: Result<[Scene]>, index: Int) -> (Int, Result<[Scene]>) in
                return (index, result) })
            .filter({ (index: Int, result: Result<[Scene]>) -> Bool in
                if index == 0 && result.isError() {
                    self.getScenes(experienceId: experienceId)
                    return false
                }
                else { return true }
            })
            .map { (index: Int, result: Result<[Scene]>) -> Result<[Scene]> in return result }
    }

    func refreshScenes(experienceId: String) {
        getScenes(experienceId: experienceId)
    }

    func createScene(_ experienceId: String, _ title: String, _ description: String, _ latitude: Double, _ longitude: Double) -> Observable<Result<Scene>> {
        return apiRepo.createScene(experienceId, title, description, latitude, longitude)
            .do(onNext: { result in
                switch result.status {
                case .success:
                    self.cacheStore[experienceId]!.addOrUpdate([result.data!])
                case .error: break
                case .inProgress: break
                }
            })
    }

    func uploadPicture(_ sceneId: String, _ image: UIImage) {
        _ = apiRepo.uploadPicture(sceneId, image)
            .subscribe { event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        let experienceId = result.data!.experienceId
                        self.cacheStore[experienceId]!.update([result.data!])
                    case .error: break
                    case .inProgress: break
                    }
                case .error(let error): fatalError(error.localizedDescription)
                case .completed: break
                }
            }
    }

    private func getScenes(experienceId: String) {
        _ = apiRepo.scenesObservable(experienceId: experienceId)
            .subscribe { event in
                switch event {
                case .next(let result):
                    self.cacheStore[experienceId]?.replaceResult(result)
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed: break
                }
        }
    }
}
