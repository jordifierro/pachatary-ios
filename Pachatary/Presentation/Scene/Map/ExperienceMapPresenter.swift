import Swift
import RxSwift

class ExperienceMapPresenter {
    
    let sceneRepo: SceneRepository
    let mainScheduler: ImmediateSchedulerType
    
    var view: ExperienceMapView!
    var experienceId: String!
    var sceneId: String?
    
    init(_ sceneRepository: SceneRepository, _ mainScheduler: ImmediateSchedulerType) {
        self.sceneRepo = sceneRepository
        self.mainScheduler = mainScheduler
    }
    
    func create() {
        getScenes()
    }
    
    func sceneClick(_ sceneId: String) {
        view.setResult(sceneId)
        view.finish()
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
                        if (self.sceneId != nil) { self.view.selectScene(self.sceneId!) }
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
}
