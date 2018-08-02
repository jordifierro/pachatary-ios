import Swift
import RxSwift

class SceneDependencyInjector {
    
    static var sceneListPresenter: ExperienceScenesPresenter { get { return
        ExperienceScenesPresenter(
            SceneDataDependencyInjector.sceneRepository,
            ExperienceDataDependencyInjector.experienceRepository,
            AppPresentationDependencyInjector.mainScheduler) }
    }
}
