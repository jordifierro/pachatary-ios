import Swift
import RxSwift
import Moya

class ProfileDependencyInjector {
    
    static func profilePresenter(view: ProfileView, username: String) -> ProfilePresenter {
        return ProfilePresenter(ExperienceDataDependencyInjector.experienceRepository,
                                ProfileDataDependencyInjector.profileRepository,
                                AppPresentationDependencyInjector.mainScheduler, view, username)
    }

    static func profileRouterPresenter(view: ProfileRouterView,
                                       username: String) -> ProfileRouterPresenter {
        return ProfileRouterPresenter(AuthDataDependencyInjector.authRepository,
                                      AppPresentationDependencyInjector.mainScheduler,
                                      view, username)
    }
}


