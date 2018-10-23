import Swift
import RxSwift

class WelcomePresenter {
    
    var authRepository: AuthRepository!
    var mainScheduler: ImmediateSchedulerType!
    var view: WelcomeView!
    
    init(_ authRepository: AuthRepository, _ mainScheduler: ImmediateSchedulerType) {
        self.authRepository = authRepository
        self.mainScheduler = mainScheduler
    }
    
    func onStartClick() {
        _ = authRepository.getPersonInvitation()
            .observeOn(mainScheduler)
            .subscribe { event in
                switch event {
                case .next(let result):
                    switch result.status {
                    case .success:
                        self.view.navigateToMain()
                    case .error:
                        self.view.enableButtons()
                        self.view.showLoader(false)
                        self.view.showError()
                    case .inProgress:
                        self.view.disableButtons()
                        self.view.showLoader(true)
                    }
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed: break
                }
            }
    }
    
    func onLoginClick() {
        view.navigateToLogin()
    }

    func onPrivacyPolicyClick() {
        view.navigateToPrivacyPolicy()
    }

    func onTermsAndConditionsClick() {
        view.navigateToTermsAndConditions()
    }
}

