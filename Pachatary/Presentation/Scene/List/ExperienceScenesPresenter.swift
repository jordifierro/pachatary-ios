import Swift
import RxSwift

class ExperienceScenesPresenter {
    
    var view: ExperienceScenesView!
    var experienceId: String!
    var sceneRepo: SceneRepository!
    var experienceRepo: ExperienceRepository!
    var mainScheduler: ImmediateSchedulerType!
    
    init(_ sceneRepo: SceneRepository, _ experienceRepo: ExperienceRepository,
         _ mainScheduler: ImmediateSchedulerType) {
        self.sceneRepo = sceneRepo
        self.experienceRepo = experienceRepo
        self.mainScheduler = mainScheduler
    }
    
    func create() {
        _ = Observable.combineLatest(sceneRepo.scenesObservable(experienceId: experienceId)
                                                    .filter { result in return result.isSuccess() },
                                     experienceRepo.experienceObservable(experienceId))
        { sceneResult, experienceResult in return (sceneResult, experienceResult) }
            .observeOn(mainScheduler)
            .subscribe { event in
                switch event {
                case .next(let (sceneResult, experienceResult)):
                    switch sceneResult.status {
                    case .success:
                        self.view.showScenes(sceneResult.data!,
                                             experience: experienceResult.data!)
                    case .error: break
                    case .inProgress: break
                    }
                case .error(_): break
                case .completed: break
                }
            }
    }
    
    func onGoToMapClick() {
        view.navigateToMap(nil)
    }

    func onLocateSceneClick(_ sceneId: String) {
        view.navigateToMap(sceneId)
    }
}

