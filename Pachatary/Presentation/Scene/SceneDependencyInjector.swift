import Swift
import RxSwift

class SceneDependencyInjector {
    
    static func experienceScenesPresenter(view: ExperienceScenesView,
                                          experienceId: String,
                                          canNavigateToProfile: Bool,
                                          isExperienceEditableIfMine: Bool)
                                                                    -> ExperienceScenesPresenter {
        return ExperienceScenesPresenter(
            SceneDataDependencyInjector.sceneRepository,
            ExperienceDataDependencyInjector.experienceRepository,
            AppPresentationDependencyInjector.mainScheduler,
            view, experienceId, canNavigateToProfile, isExperienceEditableIfMine)
    }
}
