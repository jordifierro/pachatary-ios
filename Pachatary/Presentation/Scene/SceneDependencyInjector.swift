import Swift
import RxSwift

class SceneDependencyInjector {
    
    static var sceneListPresenter: SceneListPresenter { get { return
        SceneListPresenter(
            SceneDataDependencyInjector.sceneRepository,
            ExperienceDataDependencyInjector.experienceRepository,
            AppPresentationDependencyInjector.mainScheduler) }
    }
}
