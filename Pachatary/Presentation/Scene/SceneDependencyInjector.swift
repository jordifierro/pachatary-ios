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

    static func createScenePresenter(view: CreateSceneView, experienceId: String)
                                                                           -> CreateScenePresenter {
            return CreateScenePresenter(SceneDataDependencyInjector.sceneRepository,
                                        AppPresentationDependencyInjector.mainScheduler,
                                        view, experienceId)
    }

    static func editScenePresenter(view: EditSceneView,
                                   experienceId: String, sceneId: String) -> EditScenePresenter {
            return EditScenePresenter(SceneDataDependencyInjector.sceneRepository,
                                      AppPresentationDependencyInjector.mainScheduler,
                                      view, experienceId, sceneId)
    }
}
