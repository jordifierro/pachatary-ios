import Swift
import RxSwift
import Moya

class ExperienceDependencyInjector {
    
    static func exploreExperiencePresenter(view: ExploreExperiencesView) -> ExploreExperiencesPresenter {
        return ExploreExperiencesPresenter(ExperienceDataDependencyInjector.experienceRepository,
                                           AppPresentationDependencyInjector.mainScheduler, view)
    }
    
    static var experienceMapPresenter: ExperienceMapPresenter { get { return
        ExperienceMapPresenter(
        SceneDataDependencyInjector.sceneRepository,
        AppPresentationDependencyInjector.mainScheduler) }
    }
}
