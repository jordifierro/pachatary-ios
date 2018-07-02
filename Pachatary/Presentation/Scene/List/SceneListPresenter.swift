import Swift
import RxSwift

class SceneListPresenter {
    
    var view: SceneListView!
    var experienceId: String!
    var sceneId: String!
    var sceneRepo: SceneRepository!
    var mainScheduler: ImmediateSchedulerType!
    
    init(_ sceneRepo: SceneRepository, _ mainScheduler: ImmediateSchedulerType) {
        self.sceneRepo = sceneRepo
        self.mainScheduler = mainScheduler
    }
    
    func create() {
        _ = sceneRepo.scenesObservable(experienceId: experienceId)
            .observeOn(mainScheduler)
            .subscribe { event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.showScenes(result.data!, showSceneWithId: self.sceneId)
                    case .error: break
                    case .inProgress: break
                    }
                case .error(_): break
                case .completed: break
                }
            }
    }
}

