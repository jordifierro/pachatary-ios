import Swift
import RxSwift
import Moya

class ExperienceDependencyInjector {
    
    static func exploreExperiencePresenter(view: ExploreExperiencesView) -> ExploreExperiencesPresenter {
        return ExploreExperiencesPresenter(ExperienceDataDependencyInjector.experienceRepository,
                                           AppPresentationDependencyInjector.mainScheduler, view)
    }
    
    static func savedExperiencePresenter(view: SavedExperiencesView) -> SavedExperiencesPresenter {
        return SavedExperiencesPresenter(ExperienceDataDependencyInjector.experienceRepository,
                                         AppPresentationDependencyInjector.mainScheduler, view)
    }

    static func myExperiencesPresenter(view: MyExperiencesView) -> MyExperiencesPresenter {
        return MyExperiencesPresenter(ExperienceDataDependencyInjector.experienceRepository,
                                      ProfileDataDependencyInjector.profileRepository,
                                      AuthDataDependencyInjector.authRepository,
                                      AppPresentationDependencyInjector.mainScheduler, view)
    }
    
    static var experienceMapPresenter: ExperienceMapPresenter { get { return
        ExperienceMapPresenter(
        SceneDataDependencyInjector.sceneRepository,
        AppPresentationDependencyInjector.mainScheduler) }
    }

    static func experienceRouterPresenter(view: ExperienceRouterView,
                                          experienceShareId: String) -> ExperienceRouterPresenter {
        return ExperienceRouterPresenter(AuthDataDependencyInjector.authRepository,
                                         ExperienceDataDependencyInjector.experienceRepository,
                                         AppPresentationDependencyInjector.mainScheduler,
                                         view, experienceShareId)
    }
}
