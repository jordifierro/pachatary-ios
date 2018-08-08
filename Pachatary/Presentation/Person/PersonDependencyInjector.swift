import Swift
import RxSwift

class PersonDependencyInjector {
    
    static var welcomePresenter: WelcomePresenter { get { return
        WelcomePresenter(
            AuthDataDependencyInjector.authRepository,
            AppPresentationDependencyInjector.mainScheduler) }
    }
}
