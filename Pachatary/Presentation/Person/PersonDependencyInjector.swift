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
}
