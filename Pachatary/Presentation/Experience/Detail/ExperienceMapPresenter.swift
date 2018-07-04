import Swift
import RxSwift

class ExperienceMapPresenter {
    
    let sceneRepo: SceneRepository
    let experienceRepo: ExperienceRepository
    let mainScheduler: ImmediateSchedulerType
    
    var view: ExperienceMapView!
    var experienceId: String!
    
    init(_ sceneRepository: SceneRepository,
         _ experienceRepository: ExperienceRepository,
         _ mainScheduler: ImmediateSchedulerType) {
        self.sceneRepo = sceneRepository
        self.experienceRepo = experienceRepository
        self.mainScheduler = mainScheduler
    }
    
    func create() {
        getScenes()
        getExperience()
    }
    
    func sceneClick(_ sceneId: String) {
        view.navigateToSceneList(with: sceneId)
    }
    
    func saveClick() {
        experienceRepo.switchExperienceSaveState(experienceId)
    }
    
    private func getScenes() {
        _ = self.sceneRepo.scenesObservable(experienceId: experienceId)
            .observeOn(self.mainScheduler)
            .subscribe { event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.showScenes(result.data!)
                    case .error:
                        self.view.finish()
                    case .inProgress: break
                    }
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed: break
                }
        }
    }
    
    private func getExperience() {
        _ = self.experienceRepo.experienceObservable(experienceId)
            .observeOn(self.mainScheduler)
            .subscribe { event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.showExperience(result.data!)
                    case .error: break
                    case .inProgress: break
                    }
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed: break
                }
        }
    }
}
