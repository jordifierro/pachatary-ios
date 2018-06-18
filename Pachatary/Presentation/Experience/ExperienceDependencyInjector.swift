import Swift
import RxSwift
import Moya

class ExperienceDependencyInjector {
    
    static var exploreExperiencePresenter: ExploreExperiencesPresenter { get {
        return ExploreExperiencesPresenter(
            ExperienceDataDependencyInjector.experienceRepository,
            AuthDataDependencyInjector.authRepository,
            AppPresentationDependencyInjector.mainScheduler) }
    }
}

