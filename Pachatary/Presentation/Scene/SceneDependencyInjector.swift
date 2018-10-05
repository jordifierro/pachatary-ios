import Swift
import RxSwift

class SceneDependencyInjector {
    
    static func sceneListPresenter(view: ExperienceScenesView,
                                   experienceId: String) -> ExperienceScenesPresenter {
        return ExperienceScenesPresenter(
            SceneDataDependencyInjector.sceneRepository,
            ExperienceDataDependencyInjector.experienceRepository,
            AppPresentationDependencyInjector.mainScheduler,
            view, experienceId)
    }
}
