import Swift
import RxSwift

class ExperienceScenesPresenter {
    
    let sceneRepo: SceneRepository!
    let experienceRepo: ExperienceRepository!
    let mainScheduler: ImmediateSchedulerType!
    unowned let view: ExperienceScenesView
    let experienceId: String!
    var selectedSceneId: String? = nil
    var disposable: Disposable?
    
    init(_ sceneRepo: SceneRepository, _ experienceRepo: ExperienceRepository,
         _ mainScheduler: ImmediateSchedulerType, _ view: ExperienceScenesView,
         _ experienceId: String) {
        self.sceneRepo = sceneRepo
        self.experienceRepo = experienceRepo
        self.mainScheduler = mainScheduler
        self.view = view
        self.experienceId = experienceId
    }
    
    func create() {
        disposable = Observable.combineLatest(sceneRepo.scenesObservable(experienceId: experienceId)
                                                    .filter { result in return result.isSuccess() },
                                     experienceRepo.experienceObservable(experienceId))
        { sceneResult, experienceResult in return (sceneResult, experienceResult) }
            .observeOn(mainScheduler)
            .subscribe { [unowned self] event in
                switch event {
                case .next(let (sceneResult, experienceResult)):
                    switch sceneResult.status {
                    case .success:
                        self.view.showScenes(sceneResult.data!,
                                             experience: experienceResult.data!)
                    case .error: break
                    case .inProgress: break
                    }
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed: break
                }
            }
    }

    func resume() {
        if (selectedSceneId != nil) {
            view.scrollToScene(selectedSceneId!)
            selectedSceneId = nil
        }
    }

    func destroy() {
        self.disposable?.dispose()
    }
    
    func onGoToMapClick() {
        view.navigateToMap(nil)
    }

    func onLocateSceneClick(_ sceneId: String) {
        view.navigateToMap(sceneId)
    }
    
    func saveExperience(save: Bool) {
        experienceRepo.saveExperience(self.experienceId, save: save)
    }
}
