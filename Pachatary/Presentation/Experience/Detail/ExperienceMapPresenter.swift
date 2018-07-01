import Swift
import RxSwift

class ExperienceMapPresenter {
    
    let sceneRepo: SceneRepository
    let mainScheduler: ImmediateSchedulerType
    
    var view: ExperienceMapView!
    var experienceId: String!
    
    init(_ sceneRepository: SceneRepository,
         _ mainScheduler: ImmediateSchedulerType) {
        self.sceneRepo = sceneRepository
        self.mainScheduler = mainScheduler
    }
    
    func create() {
        getScenes()
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
}



