import Swift
import RxSwift

class PersonDependencyInjector {
    
    static var welcomePresenter: WelcomePresenter { get { return
        WelcomePresenter(
            AuthDataDependencyInjector.authRepository,
            AppPresentationDependencyInjector.mainScheduler) }
    }
    
    static var askLoginEmailPresenter: AskLoginEmailPresenter { get { return
        AskLoginEmailPresenter(
            AuthDataDependencyInjector.authRepository,
            AppPresentationDependencyInjector.mainScheduler) }
    }
    
    static var loginPresenter: LoginPresenter { get { return
        LoginPresenter(
            AuthDataDependencyInjector.authRepository,
            AppPresentationDependencyInjector.mainScheduler) }
    }

    static func registerPresenter(view: RegisterView) -> RegisterPresenter {
        return RegisterPresenter(AuthDataDependencyInjector.authRepository,
                                 AppPresentationDependencyInjector.mainScheduler, view)
    }

}
